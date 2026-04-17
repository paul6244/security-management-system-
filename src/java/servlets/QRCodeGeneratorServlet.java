package servlets;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * Servlet to generate QR codes for attendance
 */
@WebServlet("/QRCodeGenerator")
public class QRCodeGeneratorServlet extends HttpServlet {

    private static final int QR_CODE_SIZE = 300;
    private static final String BASE_URL = "qrAttendance.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get parameters
        String staffId = request.getParameter("staffId");
        String dateParam = request.getParameter("date");
        
        // Use today's date if not provided
        String date = (dateParam != null && !dateParam.isEmpty()) ? 
                     dateParam : LocalDate.now().format(DateTimeFormatter.ISO_LOCAL_DATE);
        
        // Validate staff ID
        if (staffId == null || staffId.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Staff ID is required");
            return;
        }
        
        // Generate the attendance URL
        String attendanceUrl = String.format("%s?staffId=%s&date=%s", BASE_URL, staffId, date);
        
        // Generate QR code
        try {
            QRCodeWriter qrCodeWriter = new QRCodeWriter();
            BitMatrix bitMatrix = qrCodeWriter.encode(attendanceUrl, BarcodeFormat.QR_CODE, QR_CODE_SIZE, QR_CODE_SIZE);
            
            // Set response content type
            response.setContentType("image/png");
            response.setHeader("Content-Disposition", "inline; filename=\"qrcode.png\"");
            
            // Write QR code to response output stream
            try (OutputStream outputStream = response.getOutputStream()) {
                MatrixToImageWriter.writeToStream(bitMatrix, "PNG", outputStream);
            }
            
        } catch (WriterException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating QR code: " + e.getMessage());
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
