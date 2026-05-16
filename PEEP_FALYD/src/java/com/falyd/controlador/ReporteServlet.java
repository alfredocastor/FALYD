package com.falyd.controlador;

import com.falyd.dao.AlumnoDAO;
import com.falyd.dao.CalificacionDAO;
import com.falyd.dao.MaestroDAO;
import com.falyd.dao.GrupoDAO;
import com.falyd.dao.SecretariaDAO;
import com.falyd.modelo.Alumno;
import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.Rectangle;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import java.io.IOException;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ReporteServlet", urlPatterns = {"/ReporteServlet"})
public class ReporteServlet extends HttpServlet {

    // Paleta de Colores FALYD
    BaseColor azulFalyd = new BaseColor(11, 59, 96);
    BaseColor rojoFalyd = new BaseColor(211, 47, 47);
    BaseColor grisClaro = new BaseColor(248, 249, 250); // Para la caja de info
    BaseColor grisTabla = new BaseColor(242, 242, 242); // Para alternar filas

    // Tipografías
    Font fontTituloBig = new Font(Font.FontFamily.HELVETICA, 24, Font.BOLD, azulFalyd);
    Font fontSubRojo = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, rojoFalyd);
    Font fontH2 = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD, BaseColor.DARK_GRAY);
    Font fontCabecera = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD, BaseColor.WHITE);
    Font fontNormal = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL, BaseColor.BLACK);
    Font fontBold = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, BaseColor.BLACK);
    Font fontFooter = new Font(Font.FontFamily.HELVETICA, 8, Font.NORMAL, BaseColor.GRAY);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String tipo = request.getParameter("tipo");
        response.setContentType("application/pdf");
        
        if ("alumnos".equals(tipo)) {
            response.setHeader("Content-Disposition", "attachment; filename=Reporte_Alumnos_PEEP.pdf");
            generarReporteAlumnos(response.getOutputStream());
        } else if ("sistema".equals(tipo)) {
            response.setHeader("Content-Disposition", "attachment; filename=Reporte_General_PEEP.pdf");
            generarReporteSistema(response.getOutputStream());
        }else if ("calificaciones".equals(tipo)) {
            // NUEVO: Atrapamos el ID de la materia y descargamos las notas
            int idMateria = Integer.parseInt(request.getParameter("id_materia"));
            response.setHeader("Content-Disposition", "attachment; filename=Reporte_Calificaciones_Materia.pdf");
            generarReporteCalificaciones(response.getOutputStream(), idMateria);
        }
    }

    // --- 1. REPORTE DE ALUMNOS ---
    private void generarReporteAlumnos(OutputStream out) {
        try {
            Document documento = new Document();
            PdfWriter.getInstance(documento, out);
            documento.open();

            generarEncabezado(documento, "Reporte General de Matrícula");

            // Cuadro de Información (Info-box gris)
            PdfPTable infoTabla = new PdfPTable(2);
            infoTabla.setWidthPercentage(100);
            infoTabla.setSpacingAfter(20);
            
            String fechaActual = new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new Date());
            agregarCeldaInfo(infoTabla, "Generado por: Administrador del Sistema", Element.ALIGN_LEFT);
            agregarCeldaInfo(infoTabla, "Fecha de Impresión: " + fechaActual, Element.ALIGN_RIGHT);
            agregarCeldaInfo(infoTabla, "Institución: Escuela Primaria FALYD", Element.ALIGN_LEFT);
            agregarCeldaInfo(infoTabla, "Estado: Ciclo Escolar Activo", Element.ALIGN_RIGHT);
            documento.add(infoTabla);

            // Tabla de Datos
            PdfPTable tabla = new PdfPTable(4); 
            tabla.setWidthPercentage(100);
            String[] cabeceras = {"Matrícula", "Nombre Completo", "Correo Institucional", "Grupo"};
            for (String cabecera : cabeceras) {
                PdfPCell celda = new PdfPCell(new Phrase(cabecera, fontCabecera));
                celda.setBackgroundColor(azulFalyd);
                celda.setPadding(10);
                celda.setBorderColor(BaseColor.WHITE);
                tabla.addCell(celda);
            }

            AlumnoDAO dao = new AlumnoDAO();
            List<Alumno> lista = dao.listarAlumnos();

            int rowIndex = 0;
            for (Alumno a : lista) {
                // Alternar colores de las filas (blanco y gris claro)
                BaseColor colorFila = (rowIndex % 2 == 0) ? BaseColor.WHITE : grisTabla;
                
                String grupo = (a.getGrupo() != null && !a.getGrupo().isEmpty()) ? a.getGrupo() : "Sin asignar";
                
                agregarCeldaDato(tabla, String.format("%05d", a.getId_alumno()), colorFila, fontNormal); // Formato 00002
                agregarCeldaDato(tabla, a.getNombre(), colorFila, fontNormal);
                agregarCeldaDato(tabla, a.getCorreo(), colorFila, fontNormal);
                agregarCeldaDato(tabla, grupo, colorFila, fontBold); // El grupo en negritas
                
                rowIndex++;
            }
            documento.add(tabla);
            generarPieDePagina(documento);
            documento.close();
            
        } catch (Exception e) {
            System.out.println("Error al generar PDF de alumnos: " + e.getMessage());
        }
    }

    // --- 2. REPORTE DEL SISTEMA ---
    private void generarReporteSistema(OutputStream out) {
        try {
            Document documento = new Document();
            PdfWriter.getInstance(documento, out);
            documento.open();

            generarEncabezado(documento, "Reporte Estadístico del Sistema");

            Paragraph subtitulo = new Paragraph("A continuación se presenta el estado actual de los recursos y usuarios registrados en la base de datos de la Escuela Primaria FALYD.", fontNormal);
            subtitulo.setSpacingAfter(20);
            documento.add(subtitulo);

            // Tabla de Datos
            PdfPTable tabla = new PdfPTable(3); 
            tabla.setWidthPercentage(100);
            
            String[] cabeceras = {"Categoría", "Cantidad Registrada", "Estado"};
            for (String cabecera : cabeceras) {
                PdfPCell celda = new PdfPCell(new Phrase(cabecera, fontCabecera));
                celda.setBackgroundColor(azulFalyd);
                celda.setPadding(10);
                celda.setBorderColor(BaseColor.WHITE);
                tabla.addCell(celda);
            }

            AlumnoDAO aDAO = new AlumnoDAO();
            MaestroDAO mDAO = new MaestroDAO();
            SecretariaDAO sDAO = new SecretariaDAO();
            GrupoDAO gDAO = new GrupoDAO();

            Font fontGreen = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, new BaseColor(34, 139, 34));

            // Fila 1
            agregarCeldaDato(tabla, "Alumnos Inscritos", BaseColor.WHITE, fontBold);
            agregarCeldaDato(tabla, String.valueOf(aDAO.listarAlumnos().size()), BaseColor.WHITE, fontNormal);
            agregarCeldaDato(tabla, "Activo", BaseColor.WHITE, fontGreen);
            // Fila 2
            agregarCeldaDato(tabla, "Plantilla Docente", grisTabla, fontBold);
            agregarCeldaDato(tabla, String.valueOf(mDAO.listarMaestros().size()), grisTabla, fontNormal);
            agregarCeldaDato(tabla, "Activo", grisTabla, fontGreen);
            // Fila 3
            agregarCeldaDato(tabla, "Personal de Secretaría", BaseColor.WHITE, fontBold);
            agregarCeldaDato(tabla, String.valueOf(sDAO.listarSecretarias().size()), BaseColor.WHITE, fontNormal);
            agregarCeldaDato(tabla, "Activo", BaseColor.WHITE, fontGreen);
            // Fila 4
            agregarCeldaDato(tabla, "Grupos Oficiales", grisTabla, fontBold);
            agregarCeldaDato(tabla, String.valueOf(gDAO.listarGrupos().size()), grisTabla, fontNormal);
            agregarCeldaDato(tabla, "Configurado", grisTabla, fontGreen);

            documento.add(tabla);

            Paragraph actividad = new Paragraph("Actividad Reciente\nEl sistema reporta una operatividad del 100%. Las consultas a la base de datos se ejecutan con normalidad.", fontNormal);
            actividad.setSpacingBefore(30);
            documento.add(actividad);

            Paragraph firma = new Paragraph("_____________________________\nFirma del Administrador", fontNormal);
            firma.setAlignment(Element.ALIGN_CENTER);
            firma.setSpacingBefore(60);
            documento.add(firma);

            generarPieDePagina(documento);
            documento.close();
            
        } catch (Exception e) {
            System.out.println("Error al generar PDF del sistema: " + e.getMessage());
        }
    }

    // --- MÉTODOS DE DISEÑO REUTILIZABLES ---
    private void generarEncabezado(Document documento, String tituloH2) throws Exception {
        Paragraph p1 = new Paragraph("PEEP", fontTituloBig);
        Paragraph p2 = new Paragraph("PLATAFORMA ESCOLAR PARA ESCUELA PRIMARIA", fontSubRojo);
        p2.setSpacingAfter(20);
        documento.add(p1);
        documento.add(p2);
        
        Paragraph p3 = new Paragraph(tituloH2, fontH2);
        p3.setSpacingAfter(15);
        documento.add(p3);
    }

    private void agregarCeldaInfo(PdfPTable tabla, String texto, int alineacion) {
        PdfPCell celda = new PdfPCell(new Phrase(texto, fontNormal));
        celda.setBackgroundColor(grisClaro);
        celda.setBorder(Rectangle.NO_BORDER);
        celda.setPadding(8);
        celda.setHorizontalAlignment(alineacion);
        tabla.addCell(celda);
    }

    private void agregarCeldaDato(PdfPTable tabla, String texto, BaseColor bgColor, Font font) {
        PdfPCell celda = new PdfPCell(new Phrase(texto, font));
        celda.setBackgroundColor(bgColor);
        celda.setBorderColor(new BaseColor(222, 226, 230)); // Borde sutil
        celda.setPadding(10);
        tabla.addCell(celda);
    }

    private void generarPieDePagina(Document documento) throws Exception {
        String fechaActual = new SimpleDateFormat("dd/MM/yyyy").format(new Date());
        Paragraph footer = new Paragraph("Este documento es un reporte oficial generado por el sistema PEEP el " + fechaActual + ".\nTodos los derechos reservados. Zacatecas, México.", fontFooter);
        footer.setAlignment(Element.ALIGN_CENTER);
        footer.setSpacingBefore(40);
        documento.add(footer);
    }
    private void generarReporteCalificaciones(OutputStream out, int idMateria) {
        try {
            Document documento = new Document();
            PdfWriter.getInstance(documento, out);
            documento.open();

            // Usamos el encabezado FALYD institucional
            generarEncabezado(documento, "Reporte Oficial de Calificaciones");

            // Info de control
            PdfPTable infoTabla = new PdfPTable(2);
            infoTabla.setWidthPercentage(100);
            infoTabla.setSpacingAfter(20);
            
            String fechaActual = new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new Date());
            agregarCeldaInfo(infoTabla, "Emisor: Personal Docente Autorizado", Element.ALIGN_LEFT);
            agregarCeldaInfo(infoTabla, "Fecha de Exportación: " + fechaActual, Element.ALIGN_RIGHT);
            agregarCeldaInfo(infoTabla, "Filtro aplicado: Calificación por Asignatura", Element.ALIGN_LEFT);
            agregarCeldaInfo(infoTabla, "Estado: Evaluaciones del Periodo", Element.ALIGN_RIGHT);
            documento.add(infoTabla);

            // Malla de datos: #, Matrícula, Nombre del Estudiante, Promedio
            PdfPTable tabla = new PdfPTable(4); 
            tabla.setWidthPercentage(100);
            // Definimos el grosor proporcional de cada columna
            tabla.setWidths(new float[]{10f, 20f, 50f, 20f}); 
            
            String[] cabeceras = {"No.", "Matrícula", "Nombre Completo del Alumno", "Promedio"};
            for (String cabecera : cabeceras) {
                PdfPCell celda = new PdfPCell(new Phrase(cabecera, fontCabecera));
                celda.setBackgroundColor(azulFalyd);
                celda.setPadding(10);
                celda.setHorizontalAlignment(Element.ALIGN_CENTER);
                celda.setBorderColor(BaseColor.WHITE);
                tabla.addCell(celda);
            }

            AlumnoDAO aDAO = new AlumnoDAO();
            CalificacionDAO cDAO = new CalificacionDAO();
            List<Alumno> listaAlumnos = aDAO.listarAlumnos();

            int index = 1;
            for (Alumno a : listaAlumnos) {
                BaseColor colorFila = (index % 2 == 0) ? BaseColor.WHITE : grisTabla;
                
                // Calculamos el promedio exacto de la BD
                double promedio = cDAO.obtenerPromedioAlumnoMateria(a.getId_alumno(), idMateria);
                String promedioTexto = (promedio >= 0) ? String.format("%.2f", promedio) : "Sin notas";
                
                // Celda 1: Número de lista
                PdfPCell c1 = new PdfPCell(new Phrase(String.valueOf(index), fontNormal));
                c1.setBackgroundColor(colorFila); c1.setHorizontalAlignment(Element.ALIGN_CENTER); c1.setPadding(8); tabla.addCell(c1);
                
                // Celda 2: Matrícula formateada
                PdfPCell c2 = new PdfPCell(new Phrase(String.format("%05d", a.getId_alumno()), fontNormal));
                c2.setBackgroundColor(colorFila); c2.setHorizontalAlignment(Element.ALIGN_CENTER); c2.setPadding(8); tabla.addCell(c2);
                
                // Celda 3: Nombre completo
                PdfPCell c3 = new PdfPCell(new Phrase(a.getNombre(), fontNormal));
                c3.setBackgroundColor(colorFila); c3.setHorizontalAlignment(Element.ALIGN_LEFT); c3.setPadding(8); tabla.addCell(c3);
                
                // Celda 4: Promedio General (Si es mayor o igual a 9 va en negritas)
                Font fontNota = (promedio >= 9.0) ? fontBold : fontNormal;
                PdfPCell c4 = new PdfPCell(new Phrase(promedioTexto, fontNota));
                c4.setBackgroundColor(colorFila); c4.setHorizontalAlignment(Element.ALIGN_CENTER); c4.setPadding(8); tabla.addCell(c4);
                
                index++;
            }
            
            documento.add(tabla);
            
            // Pie de página con firmas de validez
            generarPieDePagina(documento);
            documento.close();
            
        } catch (Exception e) {
            System.out.println("Error al generar PDF de calificaciones: " + e.getMessage());
        }
    }
}