## Convert from Blogdown

library(rmarkdown)
library(yaml)
library(tidyverse)
library(lubridate)

files <- dir("_posts", full.names = TRUE, recursive = TRUE)
head(files)

mdfiles <- grep("\\.md$", files, value = TRUE)
sample(mdfiles, 5)
rmdfiles <- sub("\\.md$", "\\.Rmd", mdfiles)
sample(rmdfiles, 5)

file.rename(mdfiles, rmdfiles)

render(rmdfiles[1])

strip_yml <- function(txt) {
        ind <- grep("^---", txt)
        mx <- max(ind)
        txt[-seq(1, mx)]
}

get_yml_txt <- function(txt) { 
        ind <- grep("^---", txt)
        mx <- max(ind)
        txt[seq(1, mx)]
}


rmdfiles <- dir("_posts", full.names = TRUE, recursive = TRUE,
                pattern = "\\.Rmd$")

for(i in seq_along(rmdfiles)) {
        message(i)
        
        try({
                infile <- rmdfiles[i]
                txt <- readLines(infile)
                ymltxt <- get_yml_txt(txt)
                yml <- yaml.load(ymltxt)
                yml <- yml[c("title", "author")]
                yml$date <- substr(basename(dirname(rmdfiles[i])), 1, 10)
                yml$output <- list("distill::distill_article" = list(self_contained = FALSE))
                bod <- strip_yml(txt)
                
                outfile <- tempfile()
                con <- file(outfile, "wb")
                writeLines("---", con)
                write_yaml(yml, con)
                writeLines("---", con)
                writeLines("", con)
                writeLines(bod, con)
                close(con)
                file.rename(outfile, rmdfiles[i])
        })
}

results <- map(rmdfiles, function(f) {
        try(render(f))
})





