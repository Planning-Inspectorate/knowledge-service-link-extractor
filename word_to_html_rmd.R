# ==============================================================================
# word_to_html_rmd.R
# script to convert word files to html and rmd files
# J Gerulaitis, 23/08/2022
# ==============================================================================


word_to_html_rmd <- function(input_path, output_path){
  
  # get list of word files
  word_doc_list <- list.files(path = input_path, pattern = "*.docx", full.names = TRUE)
  word_doc_list_no_path <- list.files(path = input_path, pattern = "*.docx", full.names = FALSE) 
  
  # extract file names without .docx file extension
  word_doc_name_list <- gsub(".docx", "", word_doc_list_no_path)
  
  # iterate over word files and save as .rmd and .html in the output_path
  for (i in 1:length(word_doc_list)){
    
    # convert word_doc to rmarkdown
    pandoc_convert(word_doc_list[i], to="markdown", output = paste0(output_path, "/", word_doc_name_list[i], ".rmd"), options=c(paste0("--extract-media=", output_path)))
    
    # render rmarkdown as html
    render(input = paste0(output_path, word_doc_name_list[i], ".rmd"), output_format = "html_document", output_dir = output_path)
  }
}

