# Load packages

library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)
library(tools)
library(flexdashboard)
library(scales)
library(glue)
library(ggthemes)

# Load HomeBuydee Price Model
home_buydee_price_model_path <- "...App/Data/objects/home_buydee_price_model.rds"
home_buydee_price_model <- readRDS(file = home_buydee_price_model_path)

home_buydee_price_model_preds_path <- "...App/Data/objects/home_buydee_final_combined_preds.rds"
home_buydee_price_model_preds <- readRDS(file = home_buydee_price_model_preds_path)

home_buydee_price_model_preds_cities <- home_buydee_price_model_preds %>%
  group_by(city) %>%
  summarise(Count = n()) %>%
  arrange(desc(Count))

home_buydee_price_model_preds_cities_filter <- home_buydee_price_model_preds_cities[c(0:30),]
home_buydee_price_model_preds <- merge(home_buydee_price_model_preds, home_buydee_price_model_preds_cities_filter, by = "city")

#city_options <- home_buydee_price_model$xlevels[["city"]]
#prop_options <- home_buydee_price_model$xlevels[["propertyType"]]
city_options <- unique(home_buydee_price_model_preds$`city`)
prop_options <- unique(home_buydee_price_model_preds$`propertyType`)

# Load HomeBuydee City Commentary
commentary_path <- "...App/Data/top_30_cities_commentary_v2.csv"
commentary <- read.csv(commentary_path)

# Load HomeBuydee Rate Forecasts
rate_forecast_30_path <- "...App/Data/30_yr_rate_forecast.csv"
rate_forecast_30 <- read.csv(rate_forecast_30_path)

rate_forecast_15_path <- "...App/Data/15_yr_rate_forecast.csv"
rate_forecast_15 <- read.csv(rate_forecast_15_path)

rate_forecast_30arm_path <- "...App/Data/30_yr_arm_rate_forecast.csv"
rate_forecast_30arm <- read.csv(rate_forecast_30arm_path)

rates_chart_path <- "...App/Data/mortage_rates_for_chart.csv"
rates_chart <- read.csv(rates_chart_path)


# Define UI elements

addResourcePath(prefix = "Images", directoryPath = ".../Project/Images/")

ui <- fluidPage(
    theme = bs_theme(preset = "minty"),

    tags$h1("HomeBuyDee"),
    tags$h6("Your Home-Buying Buddy!"),

    tags$head(
        tags$style(HTML("
            .top-right-image {
                position: absolute;
                top: 5px;
                right: 5px;
                z-index: 1000;
            }
            ")
        )
    ),

    tags$img(src = "Images/HomeBuyDee.png", class = "top-right-image", height = "110px"),

    navbarPage(
        title = "Hi There!",
        theme = bs_theme(preset = "minty"),
        tabPanel("Home",
            fluidRow(
                column(width = 5,
                    card(
                        card_header("Introducing HomeBuyDee!"),
                        HTML(paste(
                            "<p>At HomeBuyDee, we understand that buying a home can be a daunting task. But there's no need to worry, we're here to help! Our mission is to make your home buying experience as seamless and stress-free as possible. We recognize that you may have many questions such as, 'Is now a good time to buy?', 'Am I financially ready?', 'Can I afford this?', and 'Does the home's value match its price?'",
                            "<p>Our goal is to provide you with the answers to these questions and more through our innovative tools. Start with our Value Predictor, which uses a predictive model to help you determine the best time to buy along with how much you can expect to spend to get that dream home. Then, use our Readiness Calculator to see if the home you're interested in aligns with your financial situation, ensuring that your dream of homeownership is within reach.",
                            "<p>We are committed to providing you with realistic home buying estimates based on home characteristics, economic indicators like home price indices, and anticipated interest rate changes. Additionally, our detailed reports will guide you on the optimal purchase times and values tailored to your unique financial situation.",
                            "<p>Let HomeBuyDee be your trusted partner in the journey to owning your dream home!",
                            sep="</p>")
                        )
                    )
                ),
                column(width = 7,
                    card(
                        tags$img(src = "Images/Marketing HomeBuyDee full.png")
                    )
                )
            )
        ),

        tabPanel("Value Predictor",
            page_sidebar(
                sidebar = sidebar(
                    # Select variable for city location
                    selectInput(
                        inputId = "city",
                        label = "Location",
                        choices = city_options,
                        selected = "New Haven"),

                    # Select variable for property type
                    selectInput(
                        inputId = "propertyType",
                        label = "Property Type",
                        choices = lapply(lapply(prop_options, tolower), function(x) gsub("_", " ", x, fixed = TRUE)),
                        selected = "single family"),

                    # Input variable for no. bedrooms
                    sliderInput(
                        inputId = "bedrooms", 
                        label = "Bedrooms", 
                        value = 3,
                        min = 1,
                        max = 6,
                        step = 1),

                    # Input variable for no. bathrooms
                    sliderInput(
                        inputId = "bathrooms", 
                        label = "Bathrooms", 
                        value = 2,
                        min = 1,
                        max = 4,
                        step = .5),

                    # Input variable for living area
                    numericInput(
                        inputId = "livingArea", 
                        label = "Living Area (sq. ft.)", 
                        value = 2000,
                        min = 750,
                        max = 5000,
                        step = 100),

                    # Input variable for lot size
                    numericInput(
                        inputId = "lotSize", 
                        label = "Lot Size (sq. ft.)", 
                        value = 10000,
                        min = 0,
                        max = 30000,
                        step = 1000),

                    # Input variable for year built
                    numericInput(
                        inputId = "yearBuilt", 
                        label = "Year Built", 
                        value = 2010,
                        min = 1900,
                        max = 2023,
                        step = 1),

                    # Input variable for monthly HOA fee
                    numericInput(
                        inputId = "monthlyHoaFee",
                        label = "Monthly HOA Fee",
                        value = 500,
                        min = 0,
                        max = 3000,
                        step = 100),

                    # Input variable for Primary Distance
                    numericInput(
                        inputId = "Primary_distance", 
                        label = "Primary School Distance (mi.)", 
                        value = 1,
                        min = 0,
                        max = 5,
                        step = .25),

                    # Input variable for Primary Rating
                    sliderInput(
                        inputId = "Primary_rating", 
                        label = "Primary School Rating", 
                        value = 7,
                        min = 1,
                        max = 10,
                        step = .1),

                    # Input variable for Elementary Rating 
                    sliderInput(
                        inputId = "Elementary_rating", 
                        label = "Elementary School Rating", 
                        value = 7,
                        min = 1,
                        max = 10,
                        step = .1),

                    # Input variable for Middle Rating 
                    sliderInput(
                        inputId = "Middle_rating", 
                        label = "Middle School Rating", 
                        value = 7,
                        min = 1,
                        max = 10,
                        step = .1),

                    # Input variable for High Rating 
                    sliderInput(
                        inputId = "High_rating", 
                        label = "High School Rating", 
                        value = 7,
                        min = 1,
                        max = 10,
                        step = .1),

                    # Button to refresh prediction
                    actionButton(
                        inputId = "update_prediction",
                        label = "Generate Value") 

                    ),

                # Output: Show Prediction Results
                
                fluidRow(
                    column(width = 6,
                        card(
                            card_header("Predicted Home Price"),
                            htmlOutput("pred_text_intro"),
                            fluidRow(
                                tags$style("#lower_prediction {font-size:25px;text-align:center;vertical-align: bottom;}"),
                                column(width = 4, textOutput("lower_prediction")),
                                tags$style("#prediction {font-size:35px;text-align:center;}"),
                                column(width = 4, textOutput("prediction")),
                                tags$style("#upper_prediction {font-size:25px;text-align:center;vertical-align: bottom;}"),
                                column(width = 4, textOutput("upper_prediction"))
                            ),

                            htmlOutput("pred_text_disclaimer"),

                            htmlOutput("home_price_commentary")
                        )
                    ),
                    column(width = 6,
                        card(
                            card_header("Prediction Value"),
                            htmlOutput("gauge_explanation"),
                            gaugeOutput("prediction_gauge"),
                            htmlOutput("gauge_text")
                        )
                    )
                ),

                # Output: Show Prediction Results
                
                fluidRow(
                    column(width = 6,
                        card(
                            card_header("Recent Sales"),
                            htmlOutput("home_commentary")
                        )
                    ),
                    column(width = 6,
                        card(
                            card_header("Sample Home"),
                            uiOutput("image_example")
                        )
                    )
                ),

                card(
                    card_header("Average Home Prices over Time"),
                    plotOutput("avg_home_prices")
                )
            )

        ),
            
        tabPanel("Readiness Calculator",
            page_sidebar(
                sidebar = sidebar(
                    # Input variable for property price
                    numericInput(
                        inputId = "home_price", 
                        label = "Home Price", 
                        value = 350000,
                        min = 100000,
                        max = 700000,
                        step = 10000),

                    # Input variable for down payment
                    numericInput(
                        inputId = "home_down_payment", 
                        label = "Down Payment %", 
                        value = 10,
                        min = 3,
                        max = 50,
                        step = .5),

                    htmlOutput('downpayment'),
                    
                    # Input variable for monthly income
                    numericInput(
                        inputId = "mthly_income", 
                        label = "Monthly Income pre Tax", 
                        value = 8200,
                        min = 2000,
                        max = 15000,
                        step = 200),

                    # Input variable for monthly debt
                    numericInput(
                        inputId = "mthly_debt", 
                        label = "Monthly Debt Obligations", 
                        value = 500,
                        min = 0,
                        max = 15000,
                        step = 200),
                    
                    # Button to generate report
                    actionButton(
                        inputId = "generate_report",
                        label = "Calculate Readiness") 

                ),

                # Output: Show Prediction Results
                    
                fluidRow(
                    column(width = 6,
                        card(
                            card_header("Summary"),
                            htmlOutput("pmt_summary")
                        )
                    ),
                    column(width = 6,
                        card(
                            card_header("Interest Rates"),
                            plotOutput("forecast_rates")
                        )
                    )
                ),

                fluidRow(
                    column(width = 6,
                        card(
                            card_header("Payments"),
                            htmlOutput("monthly_pmts")
                        )
                    ),
                    column(width = 6,
                        card(
                            card_header("Affordability"),
                            htmlOutput("affordability")
                        )
                    )
                ),

                card(
                    card_header("Payment Breakdown over Time - 30 Yr Fixed"),
                    plotOutput("mortgage_pmt_breakdown_30"),
                    htmlOutput("pmt_text_disclaimer_30")
                ),

                card(
                    card_header("Payment Breakdown over Time - 15 Yr Fixed"),
                    plotOutput("mortgage_pmt_breakdown_15"),
                    htmlOutput("pmt_text_disclaimer_15")
                )

            ),

        ),

        navbarMenu("More",
            tabPanel("Resources",
                card(
                    card_header("Helpful Home-Buying Links"),
                    tags$a(href="https://www.hud.gov/topics/buying_a_home", "HUD.gov: Buying a Home"),
                    tags$a(href="https://www.investopedia.com/terms/m/mortgage.asp", "Investopedia.com: What Is a Mortgage? Types, How They Work, and Examples"),
                    tags$a(href="https://www.bankrate.com/mortgages/why-debt-to-income-matters-in-mortgages/#:~:text=Your%20debt%2Dto%2Dincome%20(,for%20a%20better%20interest%20rate.", "Bankrate.com: Why DTI Matters in Mortgages"),
                    tags$a(href="https://www.consumerfinance.gov/about-us/blog/7-factors-determine-your-mortgage-interest-rate/", "CFPB.gov: Seven factors that determine your mortgage interest rate"),
                ),
                card(
                    card_header("Site Details"),
                    "This website was built using Shiny for R.",
                    tags$a(href="https://shiny.posit.co/", "Shiny by Posit"),
                )
            ),
            tabPanel("About",
                fluidRow(
                    column(width = 12,
                        card(
                            card_header("Meet the Team!"),
                            HTML(paste(
                                    "We are students in the MS Business Analytics program at the University of Iowa. Go Hawks!", 
                                    "",
                                    "Project Manager &#128197; - Erich Mitchell", 
                                    "Development Lead &#128421; - Jason Dedas",
                                    "Report Lead &#128218; - Landon Jones",
                                    "Investment Operations &#128200; - Mirrin McDougald",
                                    sep="<br/>"))
                        )
                    )
                )
            )
        ),

        nav_item(input_dark_mode(id = NULL, mode = NULL))
    )

)

# Define server

server <- function(input, output, session) {

    observeEvent(input$update_prediction, {
        property_type <- gsub(" ", "_", toupper(input$propertyType), fixed = TRUE)

        new_inputs_vector <- c(input$city,
                property_type,
                input$bedrooms,
                input$bathrooms,
                input$livingArea,
                input$lotSize,
                input$yearBuilt,
                input$monthlyHoaFee,
                input$Primary_distance,
                input$Primary_rating,
                input$Elementary_rating,
                input$Middle_rating,
                input$High_rating)

        user_home_preds_options <- home_buydee_price_model_preds %>%
                                    filter(city == new_inputs_vector[1], 
                                            propertyType == new_inputs_vector[2],
                                            bedrooms >= as.numeric(new_inputs_vector[3]) - 2,
                                            bedrooms <= as.numeric(new_inputs_vector[3]) + 2,
                                            bathrooms >= as.numeric(new_inputs_vector[4]) - 1,
                                            bathrooms <= as.numeric(new_inputs_vector[4]) + 1,
                                            livingArea >= as.numeric(new_inputs_vector[5]) - 500,
                                            livingArea <= as.numeric(new_inputs_vector[5]) + 500,
                                            #lotSize == new_inputs_vector[6],
                                            #yearBuilt == new_inputs_vector[7],
                                            #monthlyHoaFee == new_inputs_vector[8],
                                            Primary_distance >= as.numeric(new_inputs_vector[9]) - 4,
                                            Primary_distance <= as.numeric(new_inputs_vector[9]) + 4
                                            #Primary_rating == new_inputs_vector[10],
                                            #Elementary_rating == new_inputs_vector[11],
                                            #Middle_rating == new_inputs_vector[12],
                                            #High_rating == new_inputs_vector[13]
                                            ) 


        avg_sales_ratio <- mean(home_buydee_price_model_preds[home_buydee_price_model_preds$city == new_inputs_vector[1],]$avg_sales_ratio)

        annualHomeownersInsurance_default <- mean(home_buydee_price_model_preds[home_buydee_price_model_preds$annualHomeownersInsurance != 0,]$annualHomeownersInsurance)
        annualHomeownersInsurance_user <- mean(user_home_preds_options[user_home_preds_options$annualHomeownersInsurance != 0,]$annualHomeownersInsurance)
        annualHomeownersInsurance <- ifelse(is.na(annualHomeownersInsurance_user), annualHomeownersInsurance_default, annualHomeownersInsurance_user)

        favoriteCount_default <- mean(home_buydee_price_model_preds$favoriteCount)
        favoriteCount_user <- mean(user_home_preds_options$favoriteCount)
        favoriteCount <- ifelse(is.na(favoriteCount_user), favoriteCount_default, favoriteCount_user)

        pageViewCount_default <- mean(home_buydee_price_model_preds$pageViewCount)
        pageViewCount_user <- mean(user_home_preds_options$pageViewCount)
        pageViewCount <- ifelse(is.na(pageViewCount_user), pageViewCount_default, pageViewCount_user)

        value_default <- mean(home_buydee_price_model_preds$value)
        value_user <- mean(user_home_preds_options$value)
        value <- ifelse(is.na(value_user), value_default, value_user)

        taxPaid_default <- mean(home_buydee_price_model_preds$taxPaid)
        taxPaid_user <- mean(user_home_preds_options$taxPaid)
        taxPaid <- ifelse(is.na(taxPaid_user), taxPaid_default, taxPaid_user)

        tmp_imgSrc_default <- home_buydee_price_model_preds[!is.na(home_buydee_price_model_preds$imgSrc),]
        imgSrc_default <- tmp_imgSrc_default[sample(nrow(tmp_imgSrc_default), 1),]
        tmp_imgSrc_user <- user_home_preds_options[!is.na(user_home_preds_options$imgSrc),]
        imgSrc_user <- tmp_imgSrc_user[sample(nrow(tmp_imgSrc_user), 1),]
        imgSrc <- ifelse(is.na(imgSrc_user$imgSrc), imgSrc_default$imgSrc, imgSrc_user$imgSrc)


        user_home_pred_rates_latest <- subset(head(home_buydee_price_model_preds[home_buydee_price_model_preds$dateSold == max(home_buydee_price_model_preds$dateSold),], 1),
                                select = c(`yrmo`, `px_last`, `px_last_ravg6`, `mrt_last_ravg12`, `rate`, `rate_ravg6`))

        last_year_month <- user_home_pred_rates_latest$yrmo

        px_last <- user_home_pred_rates_latest$px_last
        px_last_ravg6 <- user_home_pred_rates_latest$px_last_ravg6
        mrt_last_ravg12 <- user_home_pred_rates_latest$mrt_last_ravg12
        rate <- user_home_pred_rates_latest$rate
        rate_ravg6 <- user_home_pred_rates_latest$rate_ravg6

        user_completed_variables <- data.frame(city = c(new_inputs_vector[1]), 
                                            propertyType = c(new_inputs_vector[2]),
                                            bedrooms = c(new_inputs_vector[3]),
                                            bathrooms = c(new_inputs_vector[4]),
                                            livingArea = c(new_inputs_vector[5]),
                                            lotSize = c(new_inputs_vector[6]),
                                            yearBuilt = c(new_inputs_vector[7]),
                                            monthlyHoaFee = c(new_inputs_vector[8]),
                                            Primary_distance = c(new_inputs_vector[9]),
                                            Primary_rating = c(new_inputs_vector[10]),
                                            Elementary_rating = c(new_inputs_vector[11]),
                                            Middle_rating = c(new_inputs_vector[12]),
                                            High_rating = c(new_inputs_vector[13]),
                                            avg_sales_ratio = c(avg_sales_ratio),
                                            annualHomeownersInsurance = c(annualHomeownersInsurance),
                                            favoriteCount = c(favoriteCount),
                                            pageViewCount = c(pageViewCount),
                                            value = c(value),
                                            taxPaid = c(taxPaid),
                                            px_last = c(px_last),
                                            px_last_ravg6 = c(px_last_ravg6),
                                            mrt_last_ravg12 = c(mrt_last_ravg12),
                                            rate = c(rate),
                                            rate_ravg6 = c(rate_ravg6)
        )

        home_buydee_feature_types <- subset(home_buydee_price_model_preds[1, ],
                                        select = c(`city`,
                                        `propertyType`,
                                        `bedrooms`,
                                        `bathrooms`,
                                        `livingArea`,
                                        `lotSize`,
                                        `yearBuilt`,
                                        `monthlyHoaFee`,
                                        `Primary_distance`,
                                        `Primary_rating`,
                                        `Elementary_rating`,
                                        `Middle_rating`,
                                        `High_rating`,
                                        `avg_sales_ratio`,
                                        `annualHomeownersInsurance`,
                                        `favoriteCount`,
                                        `pageViewCount`,
                                        `value`,
                                        `taxPaid`,
                                        `px_last`,
                                        `px_last_ravg6`,
                                        `mrt_last_ravg12`,
                                        `rate`,
                                        `rate_ravg6`
                                        ))


        user_completed_variables_clean <- bind_rows(home_buydee_feature_types, user_completed_variables %>% type.convert(as.is = TRUE))[2,]

        user_prediction <- predict(home_buydee_price_model, newdata = user_completed_variables_clean, se.fit = TRUE, interval = "confidence", level = 0.90)

        lower_bound <- user_prediction$`fit`[2]
        estimate <- user_prediction$`fit`[1]
        upper_bound <- user_prediction$`fit`[3]

        output$lower_prediction <- renderText({
            dollar_format(scale = .001, suffix = "K", accuracy = 1)(lower_bound)
        })

        output$prediction <- renderText({
            dollar_format(scale = .001, suffix = "K", accuracy = 1)(estimate)
        })

        output$upper_prediction <- renderText({
            dollar_format(scale = .001, suffix = "K", accuracy = 1)(upper_bound)
        })

        output$prediction_gauge <- renderGauge({
            gauge(ifelse(((value/estimate)/avg_sales_ratio) < 1, ((value/estimate)/avg_sales_ratio) - .01, ((value/estimate)/avg_sales_ratio) + .01), 
                min = .5, 
                max = 1.2,
                sectors = gaugeSectors(success = c(1.00, 1.2),
                                        warning = c(0.8, 1.00),
                                        danger = c(.5, .8)
                ),
                abbreviateDecimals = 2                              
            )
        })

        output$gauge_explanation <- renderText({
            paste("<p style='font-size: 15px;'>HomeBuyDee estimates this type of house is of ",
            "<i>",
            ifelse(ifelse(((value/estimate)/avg_sales_ratio) < 1, ((value/estimate)/avg_sales_ratio) - .01, ((value/estimate)/avg_sales_ratio) + .01) < .8,
                "low value,",
                ifelse(ifelse(((value/estimate)/avg_sales_ratio) < 1, ((value/estimate)/avg_sales_ratio) - .01, ((value/estimate)/avg_sales_ratio) + .01) < 1,
                "average value,",
                "high value,"
                )
            ),
            "</i>",
            "with a HomeBuyDee index value of ",
            round(ifelse(((value/estimate)/avg_sales_ratio) < 1, ((value/estimate)/avg_sales_ratio) - .01, ((value/estimate)/avg_sales_ratio) + .01), 2),
            ".</p>"
            )
        })

        output$image_example <- renderUI({
            tags$img(src = paste(imgSrc))
        })


        user_home_preds_options_city <- home_buydee_price_model_preds %>%
                                    filter(city == new_inputs_vector[1]
                                            ) 

        user_home_preds_options_city$date <- as.Date(user_home_preds_options_city$date, format = "%Y-%m-%d")

        user_home_preds_options_city_chart <- user_home_preds_options_city %>% 
                                                group_by(date) %>%
                                                dplyr::summarize(`Mean Price` = mean(price, na.rm=TRUE))

        user_home_preds_options_city_chart_lt_200 <- user_home_preds_options_city %>% 
                                                        filter(price < 200000) %>% 
                                                group_by(date) %>%
                                                dplyr::summarize(`Mean Price` = mean(price, na.rm=TRUE))

        user_home_preds_options_city_chart_lt_250 <- user_home_preds_options_city %>% 
                                                        filter(price < 250000) %>% 
                                                group_by(date) %>%
                                                dplyr::summarize(`Mean Price` = mean(price, na.rm=TRUE))

        user_home_preds_options_city_chart_200_400 <- user_home_preds_options_city %>% 
                                                        filter(price >= 200000,
                                                            price < 400000) %>% 
                                                group_by(date) %>%
                                                dplyr::summarize(`Mean Price` = mean(price, na.rm=TRUE))

        user_home_preds_options_city_chart_250_500 <- user_home_preds_options_city %>% 
                                                        filter(price >= 250000,
                                                            price < 500000) %>% 
                                                group_by(date) %>%
                                                dplyr::summarize(`Mean Price` = mean(price, na.rm=TRUE))

        user_home_preds_options_city_chart_400_600 <- user_home_preds_options_city %>% 
                                                        filter(price >= 400000,
                                                            price < 600000) %>% 
                                                group_by(date) %>%
                                                dplyr::summarize(`Mean Price` = mean(price, na.rm=TRUE))

        user_home_preds_options_city_chart_gt_600 <- user_home_preds_options_city %>% 
                                                        filter(price >= 600000) %>% 
                                                group_by(date) %>%
                                                dplyr::summarize(`Mean Price` = mean(price, na.rm=TRUE))

        user_home_preds_options_city_chart_gt_500 <- user_home_preds_options_city %>% 
                                                        filter(price >= 500000) %>% 
                                                group_by(date) %>%
                                                dplyr::summarize(`Mean Price` = mean(price, na.rm=TRUE))

        output$avg_home_prices <- renderPlot({

            ggplot(data = user_home_preds_options_city_chart, aes(x = date)) +
                #geom_line(data = user_home_preds_options_city_chart, aes(y = `Mean Price`, color = 'Mean Price')) + 
                geom_line(data = user_home_preds_options_city_chart_lt_250, aes(y = `Mean Price`, color = 'Mean Price < 250k')) + 
                geom_line(data = user_home_preds_options_city_chart_250_500, aes(y = `Mean Price`, color = 'Mean Price 250k - 500k')) + 
                #geom_line(data = user_home_preds_options_city_chart_400_600, aes(y = `Mean Price`, color = 'Mean Price 400k - 600k')) + 
                geom_line(data = user_home_preds_options_city_chart_gt_500, aes(y = `Mean Price`, color = 'Mean Price > 500k')) + 
                labs(title = glue('Average Home Prices in {new_inputs_vector[1]}'),
                    x = 'Date',
                    y = 'Average Home Price') + 
                #scale_fill_manual(values=c("blue", "red", "green", "orange", "purple")) +
                scale_y_continuous(breaks = scales::pretty_breaks(n = 10), labels = scales::dollar_format()) + 
                theme_fivethirtyeight() + 
                theme(axis.title = element_text()) + 
                scale_color_fivethirtyeight("Home Ranges")

        })
        
        user_home_preds_options_city_prop <- home_buydee_price_model_preds %>%
                                    filter(city == new_inputs_vector[1], 
                                            propertyType == new_inputs_vector[2]
                                            ) 

        avg_sale_price_city <- mean(user_home_preds_options_city$`price`)
        avg_sale_price_city_prop <- mean(user_home_preds_options_city_prop$`price`)
        avg_sale_price <- ifelse(is.na(avg_sale_price_city_prop), avg_sale_price_city, avg_sale_price_city_prop)

        output$avg_sales_price <- renderText({
            dollar_format(scale = .001, suffix = "K", accuracy = 1)(avg_sale_price)
        })

        output$pred_text_intro <- renderText({
            "<p style='font-size: 15px;'>Based on your input home characteristics, HomeBuyDee estimates a price of:</p>"
        })

        output$pred_text_disclaimer <- renderText({
            "<p style='font-size: 14px;'><i>Range represents a 90% confidence interval.</i></p>"
        })

        output$gauge_text <- renderText({
            "<p style='font-size: 15px;margin-top:-100px'><i>HomeBuyDee provides a value estimate based on value/price ratios. This ratio represents a relative price index compared to homes in your area - higher numbers are better!</i></p>"
        })


        commentary_city <- commentary[commentary$city == new_inputs_vector[1],]
        price_col <- ifelse(estimate < 200000, "lt_200k", ifelse(estimate < 400000, "X200k_400k", ifelse(estimate < 600000, "X400k_600k", "gt_600k")))
        commentary_city_price <- commentary_city[, price_col]

        output$home_price_commentary <- renderText({
            paste(
                "<p style='font-size: 15px;'>",
                "Next, take your home price estimate of ",
                dollar_format(scale = .001, suffix = "K", accuracy = 1)(estimate),
                " over to the readiness calculator tab to see if you can reasonably afford a home like this!",
                "</p>")
        })
        
        output$home_commentary <- renderText({
            paste("<p>",
                commentary_city$`intro`[1],
                "</p>",
                "<p>",
                commentary_city$`avg_home_price`[1],
                " ",
                commentary_city$`avg_home_size`[1],
                "</p>",
                "<p>",
                commentary_city$`tax_rate`[1],
                " ",
                commentary_city$`taxes_paid`[1],
                "</p>",
                "<p>",
                commentary_city$`home_range_breakdown`[1],
                " ",
                commentary_city_price[1],
                "</p>")
        })

        updateNumericInput(
            session,
            inputId = "home_price",
            value = round(estimate, -3)
            )

    })

    observeEvent(input$home_down_payment,{
        output$downpayment <- renderText({
            paste("<p style='font-size: 15px;'>",
                "<i>*",
                dollar_format(scale = .001, suffix = "K", accuracy = 1)(input$home_price * input$home_down_payment / 100),
                "down payment.</i></p>"
            )
        })

    })

    observeEvent(input$mthly_debt,{
        if (input$mthly_debt > input$mthly_income) {
            updateNumericInput(
                session,
                inputId = "mthly_debt",
                value = input$mthly_income
                )
        }
    })

    observeEvent(input$generate_report,{

        mortgage <- function(principal, down_payment, interest, term) {
            principal <- principal - down_payment
            J <- interest / (12 * 100)
            N <- 12 * term
            M <- principal * J / (1 - (1 + J)^(-N))
            monthPay <<- M
            # Calculate Amortization for each Month
            Pt <- principal # current principal or amount of the loan
            currP <- NULL
            while (Pt >= 0) {
                H <- Pt * J # this is the current monthly interest
                C <- M - H # this is your monthly payment minus your monthly interest, so it is the amount of principal you pay for that month
                Q <- Pt - C # this is the new balance of your principal of your loan
                Pt <- Q # sets P equal to Q and goes back to step 1. The loop continues until the value Q (and hence P) goes to zero
                currP <- c(currP, Pt)
            }
            monthP <- c(principal, currP[1:(length(currP) - 1)]) - currP
            aDFmonth <<- data.frame(
                Month = 1:length(currP),
                Year = sort(rep(1:ceiling(N / 12), 12))[1:length(monthP)],
                Balance = c(currP[1:(length(currP))]),
                Payment = monthP + c((monthPay - monthP)[1:(length(monthP))]),
                Principal = monthP,
                Interest = c((monthPay - monthP)[1:(length(monthP))])
                )
            aDFmonth <<- subset(aDFmonth, Year <= term * 12)
            aDFyear <- data.frame(
                Amortization = tapply(aDFmonth$Balance, aDFmonth$Year, max),
                Annual_Payment = tapply(aDFmonth$Payment, aDFmonth$Year, sum),
                Annual_Principal = tapply(aDFmonth$Principal, aDFmonth$Year, sum),
                Annual_Interest = tapply(aDFmonth$Interest, aDFmonth$Year, sum),
                Year = as.factor(na.omit(unique(aDFmonth$Year)))
                )
            aDFyear <<- aDFyear
        }

        mortgage(input$home_price, input$home_down_payment * input$home_price / 100, rate_forecast_30$average[1], 30)
        pmt_30_yr_now <- monthPay
        pmt_30_yr_now_chart <- aDFyear
        mortgage(input$home_price, input$home_down_payment * input$home_price / 100, rate_forecast_15$average[1], 15)
        pmt_15_yr_now <- monthPay
        pmt_15_yr_now_chart <- aDFyear

        mortgage(input$home_price, input$home_down_payment * input$home_price / 100, rate_forecast_30$average[7], 30)
        pmt_30_yr_6m <- monthPay
        mortgage(input$home_price, input$home_down_payment * input$home_price / 100, rate_forecast_15$average[7], 15)
        pmt_15_yr_6m <- monthPay

        output$pmt_summary <- renderText({
            paste(
                "<p>",
                glue("The calculated value for your dream home is {dollar_format(scale = .001, suffix = 'K', accuracy = 1)(input$home_price)} based on the parameters entered in the Value Predictor."),
                glue("You also estimated that you are able to put {input$home_down_payment}% down on the home, leading to a total downpayment of {dollar_format(scale = .001, suffix = 'K', accuracy = .1)(input$home_down_payment * input$home_price / 100)}."),
                glue("With {dollar_format(scale = 1, suffix = '', accuracy = 2)(input$mthly_income)} of monthly income, and {dollar_format(scale = 1, suffix = '', accuracy = 2)(input$mthly_debt)} of montly debt obligations, let's look at payment options, interest rates, and the affordability of your dream home."),
                "</p>",
                "<p>",
                glue("30 Year Fixed ({ifelse(round((pmt_30_yr_now)/(input$mthly_income - input$mthly_debt) * 100, 2) < 36, 'Affordable &#128526;', ifelse(round((pmt_30_yr_now)/(input$mthly_income - input$mthly_debt) * 100, 2) < 43, 'Stretching &#128556;', 'Aggressive &#128546;'))}):"), 
                "<br>",
                "&nbsp;&nbsp;&nbsp;&nbsp;&bull;  ", glue("Rate - {round(rate_forecast_30$average[1], 2)}%"),
                "<br>",
                "&nbsp;&nbsp;&nbsp;&nbsp;&bull;  ", glue("Monthly Cost - {dollar_format(scale = 1, suffix = '', accuracy = 2)(pmt_30_yr_now)}"),
                "<br>",
                "<br>",
                glue("15 Year Fixed ({ifelse(round((pmt_15_yr_now)/(input$mthly_income - input$mthly_debt) * 100, 2) < 36, 'Affordable &#128526;', ifelse(round((pmt_15_yr_now)/(input$mthly_income - input$mthly_debt) * 100, 2) < 43, 'Stretching &#128556;', 'Aggressive &#128546;'))}):"), 
                "<br>",
                "&nbsp;&nbsp;&nbsp;&nbsp;&bull;  ", glue("Rate - {round(rate_forecast_15$average[1], 2)}%"),
                "<br>",
                "&nbsp;&nbsp;&nbsp;&nbsp;&bull;  ", glue("Monthly Cost - {dollar_format(scale = 1, suffix = '', accuracy = 2)(pmt_15_yr_now)}"),
                "</p>"
            )
        })

        output$forecast_rates <- renderPlot({
            rates_chart$datetyped <- as.Date(rates_chart$date, format = "%Y-%m-%d")
            ggplot(rates_chart, aes(x = datetyped)) +
                geom_line(aes(y = rate_15_yr, color = '15 Year Fixed')) + 
                geom_line(aes(y = rate_30_yr, color = '30 Year Fixed')) + 
                geom_vline(xintercept = as.Date("2024-07-30", format = "%Y-%m-%d"), linetype = "dotted", color = "black", linewidth = 1) +
                labs(title = 'Fixed Mortgage Forecast',
                    x = 'Date',
                    y = 'Mortgage Rates') + 
                scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) + 
                theme_fivethirtyeight() + 
                theme(axis.title = element_text()) + 
                scale_color_fivethirtyeight("Product")
                
        })

        output$monthly_pmts <- renderText({
            paste("<p>",
                "Choosing the mortgage that is right for you is a big decision. Each comes with benefits and drawbacks. Longer payment terms, but lower payments. Shorter payment terms, but higher payments. Depending on your personal situation and goals, its best to review the options available to you before making a decision.", 
                "</p>",
                "<p>",
                glue("If you choose a 30 year fixed rate mortgage, your montly payment will be <b>{dollar_format(scale = 1, suffix = '', accuracy = 2)(pmt_30_yr_now)}</b> for the life of the loan. This is based on the current interest rate of {rate_forecast_30$average[1]}% and a downpayment of {dollar_format(scale = .001, suffix = 'K', accuracy = .1)(input$home_down_payment * input$home_price / 100)}."),
                glue("Over the course of the next 6 months, we predict the interest rate for a 30 year fixed mortgage will {ifelse(rate_forecast_30$average[1] < rate_forecast_30$average[7], 'increase', 'decrease')} from {rate_forecast_30$average[1]}% to {rate_forecast_30$average[7]}%."),
                ifelse(rate_forecast_30$average[1] < rate_forecast_30$average[7], 
                    glue("The predicted increase in interest rates over the next 6 months suggests that it's best to secure a loan as soon as possible. The higher interest rate of {rate_forecast_30$average[7]}% would increase your mortgage from {dollar_format(scale = 1, suffix = '' , accuracy = 2)(pmt_30_yr_now)} to {dollar_format(scale = 1, suffix = '' , accuracy = 2)(pmt_30_yr_6m)} a month, a monthly increased spend of <b>{dollar_format(scale = 1, suffix = '' , accuracy = 2)(pmt_30_yr_6m - pmt_30_yr_now)}</b> for your mortgage."), 
                    glue("The predicted decrease in interest rates over the next 6 months suggests that it's best to wait to purchse your home until {which.min(rate_forecast_30$average)} months. The lower interest rate of {rate_forecast_30$average[which.min(rate_forecast_30$average]}% would decrease your mortgage from {dollar_format(scale = 1, suffix = '' , accuracy = 2)(pmt_30_yr_now)} to {dollar_format(scale = 1, suffix = '' , accuracy = 2)(pmt_30_yr_6m)} a month, a monthly savings of <b>{dollar_format(scale = 1, suffix = '' , accuracy = 2)(pmt_30_yr_now - pmt_30_yr_6m)}</b>.")),
                "</p>",
                "<p>",
                glue("If you choose a 15 year fixed rate mortgage, your montly payment will be <b>{dollar_format(scale = 1, suffix = '', accuracy = 2)(pmt_15_yr_now)}</b> for the life of the loan. This is based on the current interest rate of {rate_forecast_15$average[1]}% and a downpayment of {dollar_format(scale = .001, suffix = 'K', accuracy = .1)(input$home_down_payment * input$home_price / 100)}."),
                glue("Over the course of the next 6 months, we predict the interest rate for a 30 year fixed mortgage will {ifelse(rate_forecast_15$average[1] < rate_forecast_15$average[7], 'increase', 'decrease')} from {rate_forecast_15$average[1]}% to {rate_forecast_15$average[7]}%."),
                ifelse(rate_forecast_15$average[1] < rate_forecast_15$average[7], 
                    glue("The predicted increase in interest rates over the next 6 months suggests that it's best to secure a loan as soon as possible. The higher interest rate of {rate_forecast_15$average[7]}% would increase your mortgage from {dollar_format(scale = 1, suffix = '' , accuracy = 2)(pmt_15_yr_now)} to {dollar_format(scale = 1, suffix = '' , accuracy = 2)(pmt_15_yr_6m)} a month, a monthly increased spend of <b>{dollar_format(scale = 1, suffix = '' , accuracy = 2)(pmt_15_yr_6m - pmt_15_yr_now)}</b> for your mortgage."), 
                    glue("The predicted decrease in interest rates over the next 6 months suggests that it's best to wait to purchse your home until {which.min(rate_forecast_15$average)} months. The lower interest rate of {rate_forecast_15$average[which.min(rate_forecast_15$average]}% would decrease your mortgage from {dollar_format(scale = 1, suffix = '' , accuracy = 2)(pmt_15_yr_now)} to {dollar_format(scale = 1, suffix = '' , accuracy = 2)(pmt_15_yr_6m)} a month, a monthly savings of <b>{dollar_format(scale = 1, suffix = '' , accuracy = 2)(pmt_15_yr_now - pmt_15_yr_6m)}</b>.")),
                "</p>"
            )
        })

        output$affordability <- renderText({
            paste("<p>",
                glue("Having a monthly income of {dollar_format(scale = 1, suffix = '', accuracy = 2)(input$mthly_income)} and a montlhly debt obligation of {dollar_format(scale = 1, suffix = '', accuracy = 2)(input$mthly_debt)}, your initial Debt-to-income (DTI) ratio is {round((input$mthly_debt)/(input$mthly_income) * 100, 2)}%."),
                "</p>",
                "<p>",
                "<b>",ifelse(round((pmt_30_yr_now)/(input$mthly_income - input$mthly_debt) * 100, 2) < 36, "Affordable &#128526;:", ifelse(round((pmt_30_yr_now)/(input$mthly_income - input$mthly_debt) * 100, 2) < 43, "Stretching &#128556;:", "Aggressive &#128546;:")),"</b>",
                glue("Choosing a 30 year fixed rate mortgage with a target monthly payment of {dollar_format(scale = 1, suffix = '', accuracy = 2)(pmt_30_yr_now)}, will put your DTI at {round((pmt_30_yr_now)/(input$mthly_income - input$mthly_debt) * 100, 2)}%"),
                ifelse(round((pmt_30_yr_now)/(input$mthly_income - input$mthly_debt) * 100, 2) < 36,
                    glue("Your DTI is below the ideal target of 36% for banks to provide you with a mortgage. This suggests you should be able to afford and secure a 30 year fixed mortgage for your dream home."),
                    glue("Your DTI is above the ideal target of 36% for banks to provide you with a mortgage. This suggests you may be stretching your budget and it may be harder for you to get a 30 year fixed mortgage. We recommend paying off some of your current debt to lower your DTI before pursuing a home purchase with a 30 year fixed rate mortgage.")
                    ),
                "</p>",
                "<p>",
                "<b>",ifelse(round((pmt_15_yr_now)/(input$mthly_income - input$mthly_debt) * 100, 2) < 36, "Affordable &#128526;:", ifelse(round((pmt_15_yr_now)/(input$mthly_income - input$mthly_debt) * 100, 2) < 43, "Stretching &#128556;:", "Aggressive &#128546;:")),"</b>",
                glue("Choosing a 15 year fixed rate mortgage with a target monthly payment of {dollar_format(scale = 1, suffix = '', accuracy = 2)(pmt_15_yr_now)}, will put your DTI at {round((pmt_15_yr_now)/(input$mthly_income - input$mthly_debt) * 100, 2)}%"),
                ifelse(round((pmt_15_yr_now)/(input$mthly_income - input$mthly_debt) * 100, 2) < 36,
                    glue("Your DTI is below the ideal target of 36% for banks to provide you with a mortgage. This suggests you should be able to afford and secure a 15 year fixed mortgage for your dream home."),
                    glue("Your DTI is above the ideal target of 36% for banks to provide you with a mortgage. This suggests you may be stretching your budget and it may be harder for you to get a 15 year fixed mortgage. We recommend paying off some of your current debt to lower your DTI before pursuing a home purchase with a 15 year fixed rate mortgage.")
                    ),
                "</p>"
            )
        })

        output$mortgage_pmt_breakdown_30 <- renderPlot({

            ggplot(pmt_30_yr_now_chart, aes(x = as.numeric(Year))) +
                geom_line(data = pmt_30_yr_now_chart, aes(y = Annual_Payment, color = 'Annual Payment')) + 
                geom_line(data = pmt_30_yr_now_chart, aes(y = Annual_Principal, color = 'Annual Principal')) + 
                geom_line(data = pmt_30_yr_now_chart, aes(y = Annual_Interest, color = 'Annual Interest')) + 
                labs(title = 'Mortage Payment Breakdown - 30 Yr Fixed',
                    x = 'Year',
                    y = 'Payment') + 
                scale_y_continuous(breaks = scales::pretty_breaks(n = 10), labels = scales::dollar_format()) + 
                theme_fivethirtyeight() + 
                theme(axis.title = element_text()) + 
                scale_color_fivethirtyeight("")

        })

        output$mortgage_pmt_breakdown_15 <- renderPlot({

            ggplot(pmt_15_yr_now_chart, aes(x = as.numeric(Year))) +
                geom_line(data = pmt_15_yr_now_chart, aes(y = Annual_Payment, color = 'Annual Payment')) + 
                geom_line(data = pmt_15_yr_now_chart, aes(y = Annual_Principal, color = 'Annual Principal')) + 
                geom_line(data = pmt_15_yr_now_chart, aes(y = Annual_Interest, color = 'Annual Interest')) + 
                labs(title = 'Mortage Payment Breakdown - 15 Yr Fixed',
                    x = 'Year',
                    y = 'Payment') + 
                scale_y_continuous(breaks = scales::pretty_breaks(n = 10), labels = scales::dollar_format()) + 
                theme_fivethirtyeight() + 
                theme(axis.title = element_text()) + 
                scale_color_fivethirtyeight("")

        })

        output$pmt_text_disclaimer_30 <- renderText({
            "<p style='font-size: 14px;'><i>* Fixed annual payment is composed of changing principal and interest over time. Initially, the payment will be composed of more interest than principal until the balance is paid down sufficiently.</i></p>"
        })

        output$pmt_text_disclaimer_15 <- renderText({
            "<p style='font-size: 14px;'><i>* Fixed annual payment is composed of changing principal and interest over time. Initially, the payment will be composed of more interest than principal until the balance is paid down sufficiently.</i></p>"
        })

    })
}

# Create a Shiny app object

home_buydee <- shinyApp(ui = ui, server = server)

runApp(home_buydee)
