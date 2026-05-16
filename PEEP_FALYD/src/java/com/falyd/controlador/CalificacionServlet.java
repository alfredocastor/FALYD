/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.falyd.controlador;

import com.falyd.dao.CalificacionDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
/**
 *
 * @author Alfredo
 */
@WebServlet(name = "CalificacionServlet", urlPatterns = {"/CalificacionServlet"})
public class CalificacionServlet extends HttpServlet {
    
@Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        CalificacionDAO dao = new CalificacionDAO();

        if ("registrar".equals(accion)) {
            int id_alumno = Integer.parseInt(request.getParameter("id_alumno"));
            int id_tarea = Integer.parseInt(request.getParameter("id_tarea"));
            double calificacion = Double.parseDouble(request.getParameter("calificacion"));

            if (dao.registrarCalificacion(id_alumno, id_tarea, calificacion)) {
                response.sendRedirect("maestro_calificaciones.jsp?msg=exito");
            } else {
                response.sendRedirect("maestro_registrar_calificacion.jsp?msg=error");
            }
        }
    }
}