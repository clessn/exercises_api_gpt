library(tidyverse)
library(openai)

data <- read.csv("data/CleanData_Japon2022.csv")

# ----------------------- Defining SES -----------------------------------------
ses_variables <- create_chat_completion(
    model = "gpt-4",
    messages = list(
        list(
            "role" = "system",
            "content" = "You are a helpful assistant. Your role is to help a R programmer analyse survey data and output only vectors containing socio-economic status variables."
        ),
        list(
            "role" = "user",
            "content" = paste0("Please analyse all of these survey variable names carefully: ", 
            paste0(names(data), collapse = ", "), 
            ". I want you to return a single vector containing all of the socio-economic status variables (SES) in the following format: c(variable 1, variable 2, variable 3, variable 4, variable 5, variable 6, variable n). Please don't output anything else than the vector. I repeat, make sure you only return the vector containing every SES. Also, please include every single SES variable in the vector. Don't forget to include any SES.")
        )
    )
)

text <- ses_variables$choices$message.content

vector_match <- regexpr("c\\(.*\\)", text)

vector_string <- regmatches(text, vector_match)

data_ses <- data.frame(eval(parse(text = vector_string))) %>%
    rename("ses" = "eval.parse.text...vector_string..")


# ---------------------------- Renaming Variables ------------------------------

for (i in seq_along(data_ses$ses)) {
    chat_prompt <- create_chat_completion(
    model = "gpt-4",
    messages = list(
        list(
            "role" = "system",
            "content" = "You are a helpful assistant. Your role is to help a R programmer rename abreviated variables to human readable variables."
        ),
        list(
            "role" = "user",
            "content" = paste0("Please analyse this abreviated variable name carefully:", 
            paste0(print(data_ses$ses[i])), 
            ". I want you to only return a new human readable variable name. Please don't output anything else than the new variable name. I repeat, make sure you only return the new variable name. Also, please make sure the new variable name is human readable.")
        )
    )
)
    data_ses$new_name[i] <- chat_prompt$choices$message.content
}


#--------------------------- Text Analysis ------------------------------------#

data_text <- readRDS("data/text_analysis.rds") 

for (i in seq_along(data_text$phrase)) {
    chat_prompt <- create_chat_completion(
    model = "gpt-4",
    messages = list(
        list(
            "role" = "system",
            "content" = "You are a helpful assistant. Your role is to help a R programmer do text analysis by objectively evaluating the sentiment of a phrase according to conventional text analysis methods and dictionaries."
        ),
        list(
            "role" = "user",
            "content" = paste0("Please analyse this phrase carefully and evaluate its tone. 0 is negative and 1 is positive:", 
            paste0(print(data_text$phrase[i])), 
            ". I want you to only return a single number between 0 and 1. Please don't output anything else than the number. Make sure you only return the number. Also, please make sure the number is between 0 and 1.")
        )
    )
)
    data_text$tone[i] <- chat_prompt$choices$message.content
}
