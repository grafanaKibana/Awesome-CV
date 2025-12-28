.PHONY: compiled

CC = xelatex
OUTPUT_DIR = compiled
RESUME_DIR = latex/resume
CV_DIR = latex/cv
RESUME_SRCS = $(shell find $(RESUME_DIR) -name '*.tex')
CV_SRCS = $(shell find $(CV_DIR) -name '*.tex')

examples: $(foreach x, coverletter cv resume, $x.pdf)

resume.pdf: $(OUTPUT_DIR)/resume/resume.tex $(RESUME_SRCS)
	$(CC) -output-directory=$(OUTPUT_DIR) $<

cv.pdf: $(OUTPUT_DIR)/cv/cv.tex $(CV_SRCS)
	$(CC) -output-directory=$(OUTPUT_DIR) $<

coverletter.pdf: $(OUTPUT_DIR)/coverletter/coverletter.tex
	$(CC) -output-directory=$(OUTPUT_DIR) $<

clean:
	rm -rf $(OUTPUT_DIR)/*.pdf
