mortgage_calculator <- function(loan_amount, annual_interest_rate, loan_term_years) {
  # Convert annual interest rate to monthly and loan term to months
  monthly_interest_rate <- annual_interest_rate / 12 / 100
  loan_term_months <- loan_term_years * 12
  
  # Calculate the monthly payment using the formula
  monthly_payment <- (loan_amount * monthly_interest_rate) / (1 - (1 + monthly_interest_rate) ^ -loan_term_months)
  
  return(monthly_payment)
}

library(shiny)

# Define UI for the mortgage calculator
ui <- fluidPage(
  titlePanel("Mortgage Calculator"),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("loan_amount", "Loan Amount:", value = 100000, min = 1),
      numericInput("annual_interest_rate", "Annual Interest Rate (%):", value = 3.5, min = 0),
      numericInput("loan_term_years", "Loan Term (years):", value = 30, min = 1),
      actionButton("calculate", "Calculate")
    ),
    
    mainPanel(
      textOutput("monthly_payment")
    )
  )
)

# Define server logic for the mortgage calculator
server <- function(input, output) {
  observeEvent(input$calculate, {
    loan_amount <- input$loan_amount
    annual_interest_rate <- input$annual_interest_rate
    loan_term_years <- input$loan_term_years
    
    monthly_payment <- mortgage_calculator(loan_amount, annual_interest_rate, loan_term_years)
    
    output$monthly_payment <- renderText({
      paste("Your monthly payment is: $", round(monthly_payment, 2))
    })
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
