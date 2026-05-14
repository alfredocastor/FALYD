/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.falyd.controlador;

import com.falyd.dao.AlumnoDAO;
import com.falyd.modelo.Alumno;
import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import java.io.IOException;
import java.io.OutputStream;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
/**
 *
 * @author Alfredo
 */
@WebServlet(name = "ReporteServlet", urlPatterns = {"/ReporteServlet"})
public class ReporteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String tipo = request.getParameter("tipo");
        
        // Configuramos la respuesta para que el navegador sepa que es un PDF que se va a descargar
        response.setContentType("application/pdf");
        
        if ("alumnos".equals(tipo)) {
            response.setHeader("Content-Disposition", "attachment; filename=Reporte_Alumnos.pdf");
            generarReporteAlumnos(response.getOutputStream());
        } else if ("sistema".equals(tipo)) {
            response.setHeader("Content-Disposition", "attachment; filename=Reporte_Sistema.pdf");
            // Aquí llamarías al método generarReporteSistema(...)
        }
    }

    private void generarReporteAlumnos(OutputStream out) {
        try {
            Document documento = new Document();
            PdfWriter.getInstance(documento, out);
            documento.open();

            // Tipografía
            Font fontTitulo = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD, BaseColor.DARK_GRAY);
            Font fontCabecera = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD, BaseColor.WHITE);

            // Título
            Paragraph titulo = new Paragraph("PEEP - Reporte General de Matrícula", fontTitulo);
            titulo.setAlignment(Element.ALIGN_CENTER);
            titulo.setSpacingAfter(20);
            documento.add(titulo);

            // Tabla
            PdfPTable tabla = new PdfPTable(4); // 4 columnas
            tabla.setWidthPercentage(100);

            // Cabeceras de la tabla
            String[] cabeceras = {"Matrícula", "Nombre", "Correo", "Grupo"};
            for (String cabecera : cabeceras) {
                PdfPCell celda = new PdfPCell(new Phrase(cabecera, fontCabecera));
                celda.setBackgroundColor(new BaseColor(11, 59, 96)); // Azul FALYD
                celda.setPadding(8);
                tabla.addCell(celda);
            }

            // Llenar datos desde tu base de datos
            AlumnoDAO dao = new AlumnoDAO();
            List<Alumno> lista = dao.listarAlumnos();

            for (Alumno a : lista) {
                tabla.addCell(String.valueOf(a.getId_alumno()));
                tabla.addCell(a.getNombre());
                tabla.addCell(a.getCorreo());
                tabla.addCell(a.getGrupo() != null ? a.getGrupo() : "Sin asignar");
            }

            documento.add(tabla);
            documento.close();

        } catch (Exception e) {
            System.out.println("Error al generar PDF: " + e.getMessage());
        }
    }
}
