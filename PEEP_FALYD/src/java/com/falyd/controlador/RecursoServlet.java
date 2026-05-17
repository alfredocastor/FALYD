/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.falyd.controlador;

import com.falyd.dao.RecursoDAO;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;;

/**
 *
 * @author Alfredo
 */
public class RecursoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        RecursoDAO dao = new RecursoDAO();

        if ("subir".equals(accion)) {
            String titulo = request.getParameter("titulo");
            String descripcion = request.getParameter("descripcion");
            String tipo = request.getParameter("tipo_recurso");
            String url = request.getParameter("url_recurso");
            int idMateria = Integer.parseInt(request.getParameter("id_materia"));
            int idUsuario = Integer.parseInt(request.getParameter("id_usuario_maestro"));
            
            // Si no se ingresa fecha, tomamos la fecha actual del sistema
            String fecha = request.getParameter("fecha_publicacion");
            if (fecha == null || fecha.isEmpty()) {
                fecha = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
            }

            if (dao.registrarRecurso(titulo, descripcion, tipo, url, fecha, idUsuario, idMateria)) {
                response.sendRedirect("maestro_recursos.jsp?msg=exito");
            } else {
                response.sendRedirect("maestro_subir_recurso.jsp?msg=error");
            }
        }
    }
}