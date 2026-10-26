# Reproducible historical retail transaction analysis
# Data: UCI Online Retail II (2009–2011). Run from repository root.
packages <- c("readxl","dplyr","ggplot2","lubridate","readr","tidyr","stringr","tibble")
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly=TRUE)]
if(length(missing)) stop("Install R packages: ",paste(missing,collapse=", "))
library(dplyr);library(ggplot2);library(lubridate);library(readr)
library(tidyr);library(stringr);library(tibble)
path <- "data/online_retail_II.xlsx"
if(!file.exists(path)) stop("First download UCI Online Retail II to ",path)
dir.create("outputs",recursive=TRUE,showWarnings=FALSE)
normalise <- function(x) tolower(gsub("[^A-Za-z0-9]+","_",trimws(x)))
parse_sheet <- function(sheet) {
  x <- readxl::read_excel(path,sheet=sheet)
  names(x) <- normalise(names(x))
  column <- function(keys) {
    found <- keys[keys %in% names(x)]
    if(!length(found)) stop("Missing expected column (",paste(keys,collapse="/"),") in sheet ",sheet)
    x[[found[1]]]
  }
  dates <- column(c("invoice_date","invoicedate"))
  dates <- if(inherits(dates,"POSIXt") || inherits(dates,"Date")) {
    as.POSIXct(dates,tz="UTC")
  } else if(is.numeric(dates)) {
    as.POSIXct(dates*86400,origin="1899-12-30",tz="UTC")
  } else {
    suppressWarnings(as.POSIXct(as.character(dates),tz="UTC"))
  }
  tibble(invoice=as.character(column(c("invoice","invoice_no","invoiceno"))),
    stock_code=as.character(column(c("stock_code","stockcode"))),
    description=as.character(column("description")),
    quantity=as.numeric(column("quantity")),date=dates,
    price=as.numeric(column(c("price","unit_price","unitprice"))),
    customer_id=as.character(column(c("customer_id","customerid"))),
    country=as.character(column("country")),source_sheet=as.character(sheet))
}
raw <- bind_rows(lapply(readxl::excel_sheets(path),parse_sheet))
if(!nrow(raw) || all(is.na(raw$date))) stop("Data missing or dates could not be parsed.")
raw <- raw %>% mutate(
  customer_id=na_if(trimws(customer_id),""),
  customer_id=if_else(customer_id %in% c("NA","nan","<NA>"),NA_character_,customer_id),
  cancellation=coalesce(str_detect(invoice,"^[Cc]"),FALSE) | coalesce(quantity<0,FALSE),
  valid_purchase=!cancellation & !is.na(invoice) & !is.na(date) &
    !is.na(quantity) & quantity>0 & !is.na(price) & price>0,
  purchase_value=if_else(valid_purchase,quantity*price,NA_real_),
  # Source sheet prevents repeated invoice numbers across the two yearly sheets.
  order_key=paste(source_sheet,invoice,sep="::")
)
quality <- tibble(metric=c("lines_total","lines_purchases","lines_cancelled_or_negative",
  "lines_missing_customer_id","lines_missing_date"),
  value=c(nrow(raw),sum(raw$valid_purchase),sum(raw$cancellation),
    sum(is.na(raw$customer_id)),sum(is.na(raw$date))))
write_csv(quality,"outputs/data_quality.csv")
sales <- raw %>% filter(valid_purchase)
if(!nrow(sales)) stop("No valid purchases after filters.")
orders <- sales %>% group_by(order_key) %>%
 summarise(date=min(date),customer_id=first(na.omit(customer_id),default=NA_character_),
 revenue=sum(purchase_value),.groups="drop") %>%
 mutate(month=floor_date(date,"month"))
monthly <- orders %>% group_by(month) %>% summarise(
  revenue=sum(revenue), orders=n(), average_order_value=revenue/orders,.groups="drop")
write_csv(monthly,"outputs/monthly_kpis.csv")
products <- sales %>% group_by(stock_code,description) %>%
 summarise(revenue=sum(purchase_value),units=sum(quantity),.groups="drop") %>%
 arrange(desc(revenue))
write_csv(products,"outputs/product_performance.csv")
known <- orders %>% filter(!is.na(customer_id))
if(nrow(known)){
 rfm <- known %>% group_by(customer_id) %>% summarise(
  last_purchase=max(date),frequency=n(),monetary=sum(revenue),.groups="drop") %>%
  mutate(recency_days=as.numeric(difftime(max(orders$date)+days(1),last_purchase,units="days")),
    recency_score=ntile(-recency_days,5),frequency_score=ntile(frequency,5),
    monetary_score=ntile(monetary,5),
    segment=case_when(recency_score>=4 & frequency_score>=4~"Active frequent",
      recency_score<=2 & monetary_score>=4~"At-risk high spend",
      frequency==1~"One-time buyer",TRUE~"Other"))
 write_csv(rfm,"outputs/customer_segments.csv")
 repeat_summary <- tibble(known_customers=nrow(rfm),
    repeat_customers=sum(rfm$frequency>=2),
    repeat_customer_share=mean(rfm$frequency>=2))
 write_csv(repeat_summary,"outputs/repeat_purchase_summary.csv")
}
plot_monthly <- ggplot(monthly,aes(month,revenue)) + geom_line(linewidth=.85) +
 geom_point(size=1.4) + theme_minimal(base_size=13) +
 labs(title="Monthly purchase revenue",subtitle="Historical retail sales; cancellations excluded",
      x=NULL,y="Positive purchase value (£)")
ggsave("outputs/monthly_revenue.png",plot_monthly,width=9,height=5,dpi=180)
top <- products %>% slice_head(n=12) %>% mutate(label=if_else(is.na(description),"Unknown",str_trunc(description,32)))
plot_products <- ggplot(top,aes(reorder(label,revenue),revenue)) +
 geom_col() + coord_flip() + theme_minimal(base_size=12) +
 labs(title="Highest-revenue products",x=NULL,y="Positive purchase value (£)")
ggsave("outputs/top_products.png",plot_products,width=9,height=6,dpi=180)
message("Outputs created. Audit and interpret numbers before publishing results.")
