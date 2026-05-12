package com.falyd.controlador;

import com.falyd.dao.UsuarioDAO;
import com.falyd.modelo.Usuario;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Recibimos los datos del formulario (login.jsp)
        String correo = request.getParameter("correo");
        String pass = request.getParameter("password");
        String tipo = request.getParameter("tipo_usuario");

        // 2. Llamamos al DAO para validar en la base de datos
        UsuarioDAO dao = new UsuarioDAO();
        Usuario user = dao.validar(correo, pass, tipo);

        // 3. Tomamos una decisión
        if (user != null) {
            // ¡LOGIN EXITOSO!
            // Creamos una sesión para que el servidor recuerde quién entró
            HttpSession session = request.getSession();
            session.setAttribute("usuarioActual", user);
            
            // Redirigimos a la pantalla correcta según su rol
            switch (user.getTipo_usuario()) {
                case "ADMIN":
                    response.sendRedirect("panel_admin.jsp");
                    break;
                case "ALUMNO":
                    response.sendRedirect("panel_alumno.jsp");
                    break;
                case "MAESTRO":
                    response.sendRedirect("panel_maestro.jsp");
                    break;
                case "SECRETARIA":
                    response.sendRedirect("panel_secretaria.jsp");
                    break;
            }
        } else {
            // LOGIN FALLIDO: Las credenciales no coinciden
            // Lo regresamos al login con una alerta de error en la URL
            response.sendRedirect("login.jsp?error=1");
        }
    }
}