# ==============================================================================
# link_processing.R
# script extract original url from web pages saved as pdf
# J Gerulaitis, 22/08/2022
# ==============================================================================

link_processing <- function(input_path, output_path){
  
  # get list of csv files with links in
  csv_doc_list <- list.files(path = input_path, pattern = "*.csv", full.names = TRUE)
  csv_doc_list_no_path <- list.files(path = input_path, pattern = "*.csv", full.names = FALSE) 
  
  # extract file names without .csv file extension
  csv_doc_name_list <- gsub(".csv", "", csv_doc_list_no_path)
  
  for(i in 1:length(csv_doc_list)){
    
    # output filename
    output_filename <- csv_doc_name_list[i]
    
    # read in list of links extracted from document
    links <- fread(csv_doc_list[i])
    
    # process 401 urls: check whether link is to a web page saved as a pdf and extract the original url if so (save this as final_url)
    # ------------------------------------------------------------------------------
    
    # extract links that have http response 401: page you were trying to access
    # cannot be loaded until you first log in with a valid user ID and password
    # these will be links hosted on Horizon
    links_401 <- links %>%
      filter(http_response == 401) %>%
      mutate(final_url = "", url_type = "")
    
    for (i in 1:nrow(links_401)){
      
      # if url is a pdf file
      if(grepl(".pdf", paste0(links_401[i,"url"]))){
        
        # try to extract data from pdf (if link is to a pdf)
        try({
          link_pdf_temp <- pdf_text(pdf = paste0(links[i,"url"]))
          
          # set final_url to be link found in footer of first page of pdf (if found)
          links_401[i,"final_url"] <- trimws(str_extract(link_pdf_temp[1], "http.*(?=1/[0-9]+\n$)"))
          
        })
        
        # if final_url contains gov.uk, assign url_type to be "gov_uk"    
        if(grepl("https://www.gov.uk", paste0(links_401[i,"final_url"]))){
          links_401[i,"url_type"] <- "gov_uk"
        }
        
        # if final_url contains intranet.planninginspectorate, assign url_type to be "internal_intranet" 
        else if(grepl("intranet.planninginspectorate.gov.uk", paste0(links_401[i,"url"]))){
          links_401[i,"url_type"] <- "internal_intranet"
          links_401[i,"final_url"] <- links_401[i,"url"]
        }
        
        # if final_url is NA, check whether url is hosted somewhere outside PINS
        else if (is.na(links_401[i,"final_url"])) {
          links_401[i,"url_type"] <- "internal_other"
          links_401[i,"final_url"] <- "REVIEW: CHECK WHETHER THIS DOC IS HOSTED OUTSIDE PINS"
        }
        
        # else assume link is "external_other"
        else{
          links_401[i,"url_type"] <- "external_other"
          links_401[i,"final_url"] <- links_401[i,"url"]
        }
      }
      
      # else if file is an PINS intranet file set url_type to "internal_intranet"
      else if(grepl("intranet.planninginspectorate.gov.uk", paste0(links_401[i,"url"]))){
        links_401[i,"url_type"] <- "internal_intranet"
        links_401[i,"final_url"] <- links_401[i,"url"]
      }
      
      # else assume link is "external_other"
      else{
        links_401[i,"url_type"] <- "internal_other"
        links_401[i,"final_url"] <- paste0(links_401[i,"url"])
      }
    }
    
    # process 403 and 200 urls: check whether url is gov.uk 
    # ------------------------------------------------------------------------------
    
    links_403_200 <- links %>%
      filter(http_response %in% c(200, 403)) %>%
      mutate("final_url" = url)
    
    links_403_200
    
    for (i in 1:nrow(links_403_200)){
      
      if(grepl("https://www.gov.uk", paste0(links_403_200[i,"final_url"]))){
        links_403_200[i,"url_type"] = "gov_uk"
      } else if(grepl("intranet.planninginspectorate.gov.uk", paste0(links_403_200[i,"final_url"]))){
        links_403_200[i,"url_type"] = "internal_intranet"
      } else {
        links_403_200[i,"url_type"] = "external_other"
      }
    }
    
    # process 404 urls:
    # ------------------------------------------------------------------------------
    
    links_404 <- links %>%
      filter(http_response == 404) %>%
      mutate("final_url" = "REVIEW AND MANUALLY UPDATE: PAGE NOT FOUND",
             "url_type" = "REVIEW AND MANUALLY UPDATE: PAGE NOT FOUND")
    
    # combine all link types:
    # ------------------------------------------------------------------------------
    
    links_comb <- rbind(links_404, links_403_200)
    links_comb <- rbind(links_comb, links_401)
    
    links_comb <- links_comb %>%
      arrange(desc(http_response), desc(final_url))
    
    # write combined links to file
    fwrite(links_comb, paste0(output_path, output_filename, "_hyperlink_list_processed.csv"))
    
  }
}





