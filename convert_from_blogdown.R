## Convert from Blogdown

library(rmarkdown)
library(yaml)
library(tidyverse)

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

txt <- read_lines(rmdfiles[1])
yml <- yaml.load(txt)
str(yml$output)
yml$output <- list("distill::distill_article" = list(self_contained = FALSE))
str(yml$output)
bod <- strip_yml(txt)

outfile <- tempfile()
con <- file(outfile, "wb")
writeLines("---", con)
write_yaml(yml, con)
writeLines("---", con)
writeLines(bod, con)
close(con)

file.show(outfile)

for(i in seq_along(rmdfiles)) {
        
        out <- try(render(rmdfiles[i]))
}