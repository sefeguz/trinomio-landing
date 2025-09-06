import PyPDF2
import os
import sys

def split_pdf(input_file, max_size_mb=30):
    """
    Split a PDF file into smaller chunks that are under the specified size limit.
    """
    # Check if file exists
    if not os.path.exists(input_file):
        print(f"Error: File {input_file} not found")
        return
    
    # Open the PDF
    with open(input_file, 'rb') as file:
        pdf_reader = PyPDF2.PdfReader(file)
        total_pages = len(pdf_reader.pages)
        
        print(f"Total pages in PDF: {total_pages}")
        
        # Get base filename
        base_name = os.path.splitext(input_file)[0]
        
        # Split the PDF
        chunk_num = 1
        current_writer = PyPDF2.PdfWriter()
        current_pages = 0
        pages_per_chunk = []
        
        for page_num in range(total_pages):
            current_writer.add_page(pdf_reader.pages[page_num])
            current_pages += 1
            
            # Save every 10 pages or at the end
            if current_pages >= 10 or page_num == total_pages - 1:
                output_file = f"{base_name}_part{chunk_num}.pdf"
                
                with open(output_file, 'wb') as output:
                    current_writer.write(output)
                
                file_size_mb = os.path.getsize(output_file) / (1024 * 1024)
                print(f"Created {output_file} - Pages {page_num - current_pages + 2} to {page_num + 1} - Size: {file_size_mb:.2f} MB")
                
                pages_per_chunk.append(current_pages)
                
                # Reset for next chunk
                current_writer = PyPDF2.PdfWriter()
                current_pages = 0
                chunk_num += 1
        
        print(f"\nSuccessfully split PDF into {chunk_num - 1} parts")
        return chunk_num - 1

if __name__ == "__main__":
    input_file = "Presentación Final TRINOMIO-1_250905_192117.pdf"
    
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
    
    num_parts = split_pdf(input_file)