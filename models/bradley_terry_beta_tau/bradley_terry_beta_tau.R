sim.block <- function(subject, u, beta, tau, cfg){
  
  Noffer  <- cfg$Noffer
  Ntrials <- cfg$Ntrials
  
  df <- data.frame()
  
  for (trial in 1:Ntrials) {
    # Sample 2 distinct symptoms
    offer <- sample(1:Noffer, 2, replace = FALSE)
    
    u1 <- u[offer[1]]
    u2 <- u[offer[2]]
    
    # 1. Calculate the decoupled Softmax weights
    exp_1 <- exp(beta * u1)
    exp_2 <- exp(beta * u2)
    exp_none <- exp(tau)
    
    # 2. Calculate the denominator (sum of all weights)
    denom <- exp_1 + exp_2 + exp_none
    
    # 3. Extract the three distinct probabilities
    prob_A <- exp_1 / denom
    prob_B <- exp_2 / denom
    prob_None <- exp_none / denom
    
    # 4. Sample the choice (1 = A, 2 = B, 3 = None)
    choice_num <- sample(c(1, 2, 3), size = 1, prob = c(prob_A, prob_B, prob_None))
    
    # 5. Format as a factor
    choice <- factor(
      ifelse(choice_num == 1, "A", 
             ifelse(choice_num == 2, "B", "None")),
      levels = c("A", "B", "None"))
    
    # Keep the original boolean tracker for A
    is_choice_A <- as.numeric(choice_num == 1)
    
    # 6. Bind to the dataframe
    df <- rbind(df, data.frame(
      subject = subject,
      trial = trial,
      offer_A = offer[1],
      offer_B = offer[2],
      u1 = u1,
      u2 = u2,
      prob_A = prob_A,
      prob_B = prob_B,
      prob_None = prob_None,
      choice = choice,
      is_choice_A = is_choice_A
    ))
  }
  
  return(df)
}