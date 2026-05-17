/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.falyd.controlador;

import com.falyd.dao.MensajeDAO;
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
public class MensajeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        MensajeDAO dao = new MensajeDAO();

        if ("enviar".equals(accion)) {
            int id_emisor = Integer.parseInt(request.getParameter("id_emisor"));
            int id_receptor = Integer.parseInt(request.getParameter("id_receptor"));
            String contenido = request.getParameter("contenido");
            String origen = request.getParameter("origen");
            
            // Solo enviamos si no está vacío
            if (contenido != null && !contenido.trim().isEmpty()) {
                dao.enviarMensaje(id_emisor, id_receptor, contenido);
            }
            if ("alumno".equals(origen)) {
                response.sendRedirect("alumno_mensajes.jsp?id_maestro_user=" + id_receptor);
            } else {
                response.sendRedirect("maestro_mensajes.jsp?id_alumno=" + id_receptor);
            }
            
        }
    }
}
