/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.falyd.controlador;

import com.falyd.dao.AlumnoDAO;
import com.falyd.dao.EntregaDAO;
import com.falyd.modelo.Alumno;
import com.falyd.modelo.Usuario;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

/**
 *
 * @author Alfredo
 */
@WebServlet(name = "EntregarTareaServlet", urlPatterns = {"/EntregarTareaServlet"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 20,       // 20MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class EntregarTareaServlet extends HttpServlet {

  @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        try {
            // 1. Validar sesión
            HttpSession sesion = request.getSession();
            Usuario user = (Usuario) sesion.getAttribute("usuarioActual");
            if (user == null || !user.getTipo_usuario().equals("ALUMNO")) {
                response.sendRedirect("login.jsp");
                return;
            }

            // 2. Obtener Alumno
            AlumnoDAO aDAO = new AlumnoDAO();
            Alumno miPerfil = aDAO.obtenerAlumnoPorUsuario(user.getId_usuario());
            int idAlumno = miPerfil.getId_alumno();

            // 3. Capturar parámetros de forma SEGURA (Evita el choque por "null")
            String idTareaStr = request.getParameter("id_tarea");
            int idTarea = 1; // Valor por defecto en caso de error
            if (idTareaStr != null && !idTareaStr.equals("null") && !idTareaStr.trim().isEmpty()) {
                idTarea = Integer.parseInt(idTareaStr);
            }
            
            String comentario = request.getParameter("comentario");

            // 4. Capturar Archivo y validar que sí exista
            Part filePart = request.getPart("archivoTarea");
            if (filePart == null || filePart.getSize() == 0 || filePart.getSubmittedFileName() == null || filePart.getSubmittedFileName().isEmpty()) {
                System.out.println("ERROR: No se recibió ningún archivo.");
                response.sendRedirect("alumno_tareas.jsp?error=sin_archivo");
                return;
            }

            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            
            // 5. Crear la carpeta en la ruta real del servidor
            String uploadPath = getServletContext().getRealPath("") + File.separator + "entregas";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdir();
                System.out.println(" Carpeta 'entregas' creada en: " + uploadPath);
            }

            // 6. Guardar el archivo físicamente
            String nombreArchivoFinal = System.currentTimeMillis() + "_" + fileName;
            String filePath = uploadPath + File.separator + nombreArchivoFinal;
            filePart.write(filePath);
            System.out.println(" Archivo guardado físicamente en: " + filePath);

            // 7. Guardar en Base de Datos
            String archivoUrl = "entregas/" + nombreArchivoFinal;
            EntregaDAO eDAO = new EntregaDAO();
            boolean exito = eDAO.registrarEntrega(idTarea, idAlumno, archivoUrl, comentario);

            if (exito) {
                System.out.println("Registro de entrega insertado en MySQL con éxito.");
                response.sendRedirect("alumno_tareas.jsp?exito=true");
            } else {
                System.out.println(" ERROR: El DAO falló al insertar en MySQL.");
                response.sendRedirect("alumno_tareas.jsp?error=db");
            }

        } catch (Exception e) {
            // Si algo truena, lo veremos claramente en la consola de NetBeans
            System.out.println("EXCEPCIÓN CRÍTICA EN EntregarTareaServlet:");
            e.printStackTrace();
            response.sendRedirect("alumno_tareas.jsp?error=excepcion");
        }
    }
}