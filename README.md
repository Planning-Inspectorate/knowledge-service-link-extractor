# knowledge-service-link-extractor
`knowledge-service-link-extractor` is a proof of concept for link/document management for Word documents. It converts Word documents to HTML (and also outputs an equivalent Rmarkdown document), extracts hyperlinks from the new HTML documents and then if any of those links are to PDF documents where an HTML page has been saved as a PDF, it extracts the original URL associated with that web page. It also adds some Planning Inspectorate (PINS) specific metadata to the links to indicate whether the link is a `gov.uk` hosted page, internally hosted or other externally hosted file.

## Pre-requisites
R
RStudio/IDE

## What's in this repo
* `link_extraction_RUNFILE.R` - main wrapper that is run by user and calls on three functions.
* `word_to_html_rmd.R` - function to convert Word files into HTML/Rmarkdown (rmd) files.
* `html_link_extractor.R` - function to extract a list of external hyperlinks (i.e. not those that reference other places within the given Word file). This function also uses `GET` to get the HTTP response code for each link.
* `link_processing.R` - function to add metadata to links to give user an indication of where the link is stored (e.g. on a `gov.uk` domain) and whether the link needs to be reviewed (e.g. if it is returning a 401 or is an internally saved PDF but could be changed to be a live link hosted outside PINS).

## Running
* Download repository / clone
* Open link_extraction_RUNFILE.R in RStudio/IDE and update the following variables:
  * `input_path` - this should be location of folder containing word doc(s) to be converted to html/rmarkdown (rmd).
  * `output_dir` - parent directory to save converted Word files (.html and .rmd versions) and lists of extracted links into.
  * `word_to_html_rmd_toggle` - this should be set to TRUE or FALSE (first time running this will need to be TRUE for subsequent toggles to function)
  * `extract_hyperlinks_toggle` - this should be set to TRUE or FALSE  to indicate whether to run hyperlink extraction from .html docs (first time running this will need to be TRUE for subsequent toggles to function).
  * `link_processing_toggle` - this should be set to TRUE or FALSE to determine whether you wish to process the extracted links.
  
  ## Future developments
  Currently the conversion to .html is somewhat crude and will need some work on the formatting.
