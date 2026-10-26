# Scenario exploration for an incremental £1m annual sales target
# These are hypothetical assumptions, NOT findings of the UCI dataset.
dir.create("outputs", showWarnings = FALSE, recursive = TRUE)
base_revenue <- 10e6  # Illustrative annual baseline GBP, not sourced from data
levers <- data.frame(
  lever = c("Increase purchase frequency", "Increase average order value", "Reduce lost purchasing"),
  low = c(0.01,0.01,0.005),
  midpoint = c(0.03,0.025,0.01),
  high = c(0.05,0.04,0.02)
)
scenarios <- data.frame(
  scenario = c("Conservative","Base case","Stretch"),
  assumed_uplift = c(sum(levers$low),sum(levers$midpoint),sum(levers$high))
)
scenarios$illustrative_increment_gbp <- base_revenue * scenarios$assumed_uplift
scenarios$target_gap_gbp <- 1e6 - scenarios$illustrative_increment_gbp
scenarios$hits_target <- scenarios$illustrative_increment_gbp >= 1e6
write.csv(scenarios, "outputs/illustrative_growth_scenarios.csv", row.names = FALSE)
print(scenarios)
cat("\nASSUMPTIONS ONLY. Uplifts are illustrative, additive, and may overlap.\n")
cat("To avoid double counting in a real model, define causal separation and test responses.\n")
