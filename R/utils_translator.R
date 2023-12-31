#' Setup of virtual environment
#'
#' This function ensures that the virtual environment is prepared, which means
#' that it exists and has access to python and the required python modules.
#'
#' @param venv_name String, denoting the name of the virtual environment
#'
#' @noRd
setup_virtualenv <- function(venv_name = "languager") {

  if (!reticulate::virtualenv_exists(venv_name)) {

    if (!reticulate::py_available()) {
      reticulate::install_python()
    }

    message("Create virtual environment 'languager'")
    reticulate::virtualenv_create(
      venv_name,
      python = reticulate::py_config()$python
      )

    message("Install python modules")
    reticulate::virtualenv_install(
      venv_name,
      packages = c("torch", "transformers", "sentencepiece", "sacremoses")
      )

    message("Installation of python modules complete")
  }

  message("Start venv")
  reticulate::use_virtualenv(venv_name)
}



#' Load dependencies for an individual model
#'
#' This function loads the tokenizer and model for a specific language pair.
#'
#' @param language_pair String, specifying the pair of languages to be
#' translated. E.g. `"de-fr"`
#' @param transformers The transformers module
#' @param model_path Path to the model. If null, the default cache folder
#' (e.g. `~/.cache/huggingface/hub/`) is used.
#'
#' @return A list containing the model and tokenizer for one language pair
#'
#' @examples
#' \dontrun{load_dependencies(language_pair = "fr-de", transformers = .python_modules$transformers)}
load_dependencies <- function(language_pair = "fr-de", transformers, model_path = NULL) {

  message("start load_dependencies()")
  if (!is.null(model_path)) {
    message("Load tokenizer")
    tokenizer <- transformers$MarianTokenizer$from_pretrained(
      file.path(model_path, paste0("model_", language_pair))
    )

    message("Load model")
    model <- transformers$MarianMTModel$from_pretrained(
      file.path(model_path, paste0("model_", language_pair))
    )
  } else {
    message("Load tokenizer from ~/.cache/huggingface/hub/")
    tokenizer <- transformers$MarianTokenizer$from_pretrained(
      paste0("Helsinki-NLP/opus-mt-", language_pair)
    )
    message("Load model from ~/.cache/huggingface/hub/")
    model <- transformers$MarianMTModel$from_pretrained(
      paste0("Helsinki-NLP/opus-mt-", language_pair)
    )
  }
  message("Dependencies for ", language_pair, " loaded.")

  return(list(
    tokenizer = tokenizer, model = model
  ))
}
