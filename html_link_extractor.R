# ==============================================================================
# html_link_extractor.R
# script to pull out links to web pages from a word file saved as htm/html
# J Gerulaitis, 22/08/2022
# ==============================================================================

html_link_extractor <- function(input_path, output_path){
  
  # get list of html files
  html_doc_list <- list.files(path = input_path, pattern = "*.html", full.names = TRUE)
  html_doc_list_no_path <- list.files(path = input_path, pattern = "*.html", full.names = FALSE) 
  
  # extract file names without .docx file extension
  html_doc_name_list <- gsub(".html", "", html_doc_list_no_path)
  
  for(i in 1:length(html_doc_list)){
    
    # read in file 
    html <- read_html(html_doc_list[i])
    
    # extract all external urls (i.e. not internal links within a document)
    links <- html %>%
      
      # find all links
      html_elements("a") %>% 
      html_attr("href") %>% 
      
      # convert to dataframe
      as.data.frame() %>%
      
      # rename column as url
      rename("url" = ".") %>%
      
      # filter out urls that aren't links to a web page (e.g. internal links)
      filter(grepl("^http", url)) %>%
      
      # remove spaces added to any urls
      mutate(url = gsub("%20", "", url))
    
  }
  
  # get http response from following each link
  links$http_response <- lapply(links$url, function(x) GET(x)$status)
  
  # write list of links and http statuses to file for review
  fwrite(links, paste0(output_path, html_doc_name_list[i], "_hyperlink_list.csv"))
}


