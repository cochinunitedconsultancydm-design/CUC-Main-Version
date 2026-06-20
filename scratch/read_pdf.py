import PyPDF2
import sys

def read_pdf(file_path):
    try:
        with open(file_path, 'rb') as file:
            reader = PyPDF2.PdfReader(file)
            text = ''
            for page in reader.pages:
                text += page.extract_text() + '\n'
            print(text.strip())
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    read_pdf(sys.argv[1])
