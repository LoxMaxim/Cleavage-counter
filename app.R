library(shiny)
library(readxl)
library(writexl)
library(seqinr)
library(Biostrings)
library(shinyjs)

# Function to clean protein sequences
clean_sequences <- function(sequence_list) {
  sequence_list <- gsub("\\([^)]*\\)", "", sequence_list)
  sequence_list <- gsub("^[A-Z]\\.?", "", sequence_list)
  sequence_list <- gsub("\\.[A-Z]$", "", sequence_list)
  return(sequence_list)
}

ui <- fluidPage(
  useShinyjs(),
  titlePanel("Protein Sequence Aligner and Frequency Counter"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload Excel File", accept = ".xlsx"),
      textAreaInput("refseq", "Reference Sequence", placeholder = "Paste reference protein sequence", rows = 5),
      actionButton("run", "Run Analysis", icon = icon("play")),
      br(), br(),
      textOutput("status"),
      downloadButton("download_xlsx", "Download Results (Excel)"),
      downloadButton("download_fasta", "Download Alignment (FASTA)")
    ),
    mainPanel(
      h4("Preview of Uploaded Data"),
      tableOutput("preview"),
      h4("Preview of Output Alignment"),
      tableOutput("output_preview")
    )
  )
)

server <- function(input, output, session) {
  
  # Track processing status
  status_text <- reactiveVal("")
  output$status <- renderText({ status_text() })
  
  # Read and clean uploaded data
  preview_data <- reactive({
    req(input$file)
    df <- read_excel(input$file$datapath)
    df$Sequence <- clean_sequences(df$Sequence)
    
    # Convert any sample-like column to numeric
    sample_cols <- grep("^Sample", names(df), value = TRUE)
    for (col in sample_cols) {
      df[[col]] <- as.numeric(df[[col]])
    }
    return(df)
  })
  
  output$preview <- renderTable({
    req(preview_data())
    head(preview_data())
  })
  
  # Main processing logic
  result_data <- eventReactive(input$run, {
    req(input$refseq, preview_data())
    status_text("Running analysis...")
    
    withProgress(message = "Processing...", value = 0.1, {
      seq_df <- preview_data()
      sample_names <- grep("^Sample", names(seq_df), value = TRUE)
      
      reference_sequence <- gsub("[^A-Z]", "", toupper(input$refseq))
      validate(
        need(nchar(reference_sequence) > 10, "Reference sequence must be at least 10 amino acids.")
      )
      reference <- AAString(reference_sequence)
      ref_len <- nchar(reference_sequence)
      
      aligned_sequences <- list()
      
      # Alignment loop
      for (i in 1:nrow(seq_df)) {
        current_sequence <- AAString(seq_df$Sequence[i])
        alignment <- pairwiseAlignment(current_sequence, reference, type = "global-local")
        subject_start <- start(subject(alignment))
        subject_end <- end(subject(alignment))
        aligned_subject <- as.character(subject(alignment))
        aligned_pattern <- as.character(pattern(alignment))
        pad_left <- if (subject_start > 1) paste(rep("-", subject_start - 1), collapse = "") else ""
        pad_right <- if (subject_end < ref_len) paste(rep("-", ref_len - subject_end), collapse = "") else ""
        full_aligned_pattern <- paste0(pad_left, aligned_pattern, pad_right)
        aligned_sequences[[i]] <- full_aligned_pattern
      }
      
      # Initialize alignment_df
      alignment_df <- data.frame(
        Position = 1:ref_len,
        Residue = unlist(strsplit(reference_sequence, ""))
      )
      for (sample in sample_names) {
        alignment_df[[sample]] <- rep(0, ref_len)
      }
      
      incProgress(0.5)
      
      # Fill in frequency counts
      for (i in 1:nrow(seq_df)) {
        seq_chars <- unlist(strsplit(aligned_sequences[[i]], ""))
        for (j in 1:min(length(seq_chars), ref_len)) {
          if (seq_chars[j] != "-" && seq_chars[j] == alignment_df$Residue[j]) {
            for (sample in sample_names) {
              alignment_df[[sample]][j] <- alignment_df[[sample]][j] + seq_df[[sample]][i]
            }
          }
        }
      }
      
      # Count first and last non-gap matches
      for (i in 1:nrow(seq_df)) {
        seq_chars <- unlist(strsplit(aligned_sequences[[i]], ""))
        first_non_gap_index <- min(which(seq_chars != "-"), na.rm = TRUE)
        last_non_gap_index <- max(which(seq_chars != "-"), na.rm = TRUE)
        
        for (sample in sample_names) {
          first_col <- paste0(sample, "_First")
          last_col <- paste0(sample, "_Last")
          
          if (!(first_col %in% colnames(alignment_df))) {
            alignment_df[[first_col]] <- 0
            alignment_df[[last_col]] <- 0
          }
          
          if (!is.na(first_non_gap_index) &&
              seq_chars[first_non_gap_index] == alignment_df$Residue[first_non_gap_index]) {
            alignment_df[[first_col]][first_non_gap_index] <- alignment_df[[first_col]][first_non_gap_index] + seq_df[[sample]][i]
          }
          
          if (!is.na(last_non_gap_index) &&
              seq_chars[last_non_gap_index] == alignment_df$Residue[last_non_gap_index]) {
            alignment_df[[last_col]][last_non_gap_index] <- alignment_df[[last_col]][last_non_gap_index] + seq_df[[sample]][i]
          }
        }
      }
      
      incProgress(1)
      
      attr(alignment_df, "aligned_sequences") <- setNames(aligned_sequences, paste0("Seq_", 1:length(aligned_sequences)))
      status_text("✅ Analysis complete.")
      return(alignment_df)
    })
  })
  
  # Show output preview
  output$output_preview <- renderTable({
    req(result_data())
    head(result_data())
  })
  
  # Excel download
  output$download_xlsx <- downloadHandler(
    filename = function() {
      paste0("Alignment_results_", Sys.Date(), ".xlsx")
    },
    content = function(file) {
      write_xlsx(result_data(), path = file)
    }
  )
  
  # FASTA download
  output$download_fasta <- downloadHandler(
    filename = function() {
      paste0("alignment_output_", Sys.Date(), ".fasta")
    },
    content = function(file) {
      aligned_seqs <- attr(result_data(), "aligned_sequences")
      write.fasta(sequences = aligned_seqs, names = names(aligned_seqs), file.out = file)
    }
  )
}

shinyApp(ui, server)
