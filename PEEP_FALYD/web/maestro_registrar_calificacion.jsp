<%@page import="com.falyd.modelo.Tarea"%>
<%@page import="com.falyd.dao.TareaDAO"%>
<%@page import="com.falyd.modelo.Alumno"%>
<%@page import="com.falyd.dao.AlumnoDAO"%>
<%@page import="java.util.List"%>
<%@page import="com.falyd.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");

    if (user == null || !user.getTipo_usuario().equals("MAESTRO")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registrar Calificación - FALYD</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        :root { --blue-falyd: #0b3b60; --red-falyd: #d32f2f; --bg-light: #f4f7fe; --text-main: #2b3674; --border-color: #e2e8f0; }
        body { background-color: var(--bg-light); font-family: 'Segoe UI', sans-serif; color: var(--text-main); }
        .sidebar { width: 260px; height: 100vh; position: fixed; background: white; z-index: 100; border-bottom-right-radius: 50px; }
        .nav-link { color: #8f9bba; padding: 12px 25px; font-weight: 600; margin: 4px 15px; border-radius: 10px; }
        .nav-link:hover, .nav-link.active { background-color: #e3f2fd; color: var(--blue-falyd); }
        .main-content { margin-left: 260px; padding: 30px 40px; padding-bottom: 80px;}
        .form-container { background: white; border-radius: 20px; padding: 40px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); }
        .btn-submit { background: var(--blue-falyd); color: white; font-weight: 600; border-radius: 10px; padding: 10px 25px; border: none;}
        .grade-input { font-size: 2rem; font-weight: bold; text-align: center; color: var(--blue-falyd); padding: 15px; border-radius: 15px; }
    </style>
</head>
<body>

    <div class="sidebar d-flex flex-column">
        <div class="p-4 text-center"><img src="img/Logo.png" width="120"></div>
        <nav class="nav flex-column mt-2 flex-grow-1">
            <a class="nav-link" href="panel_maestro.jsp"><i class="bi bi-house-door-fill me-2"></i> Inicio</a>
            <a class="nav-link" href="maestro_tareas.jsp"><i class="bi bi-check2-square me-2"></i> Tareas</a>
            <a class="nav-link" href="maestro_calendario.jsp"><i class="bi bi-calendar3 me-2"></i> Calendario</a>
            <a class="nav-link" href="maestro_alumnos.jsp"><i class="bi bi-people-fill me-2"></i> Alumnos</a>
            <a class="nav-link active" href="maestro_calificaciones.jsp"><i class="bi bi-clipboard-data me-2"></i> Calificaciones</a>
            <a class="nav-link" href="#"><i class="bi bi-book me-2"></i> Recursos</a>
        </nav>
    </div>

    <div class="main-content">
        <div class="mb-4">
            <a href="maestro_calificaciones.jsp" class="text-decoration-none fw-bold text-muted">
                <i class="bi bi-arrow-left me-1"></i> Calificaciones <span class="mx-2">/</span> <span style="color: var(--blue-falyd);">Registrar nueva</span>
            </a>
        </div>

        <div class="form-container">
            <div class="d-flex align-items-center mb-5">
                <div class="me-3" style="font-size: 2.5rem; color: #38a169;"><i class="bi bi-journal-check"></i></div>
                <div>
                    <h2 class="fw-bold mb-1">Registrar calificación</h2>
                    <p class="text-muted mb-0">Asigna la nota a un alumno por una tarea específica.</p>
                </div>
            </div>

            <form action="CalificacionServlet" method="POST">
                <input type="hidden" name="accion" value="registrar">
                
                <h5 class="fw-bold border-bottom pb-2 mb-4">Datos de Evaluación</h5>
                <div class="row g-4 mb-5">
                    <div class="col-md-6">
                        <label class="form-label fw-bold small">Selecciona la Tarea / Actividad <span class="text-danger">*</span></label>
                        <select name="id_tarea" class="form-select" required>
                            <option value="" selected disabled>Elige la tarea a calificar...</option>
                            <%
                                TareaDAO tDAO = new TareaDAO();
                                List<Tarea> listaTareas = tDAO.listarTareasPorMaestro(user.getId_usuario());
                                for(Tarea t : listaTareas) {
                            %>
                                <option value="<%= t.getId_tarea() %>"><%= t.getNombre_materia() %> - <%= t.getTitulo() %></option>
                            <% } %>
                        </select>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-bold small">Selecciona al Alumno <span class="text-danger">*</span></label>
                        <select name="id_alumno" class="form-select" required>
                            <option value="" selected disabled>Elige al alumno...</option>
                            <%
                                AlumnoDAO aDAO = new AlumnoDAO();
                                List<Alumno> listaAlumnos = aDAO.listarAlumnos();
                                for(Alumno a : listaAlumnos) {
                            %>
                                <option value="<%= a.getId_alumno() %>"><%= String.format("%05d", a.getId_alumno()) %> - <%= a.getNombre() %></option>
                            <% } %>
                        </select>
                    </div>
                </div>

                <h5 class="fw-bold border-bottom pb-2 mb-4">Calificación</h5>
                <div class="row g-4 mb-4 align-items-center justify-content-center">
                    <div class="col-md-4 text-center">
                        <label class="form-label fw-bold">Nota Asignada <span class="text-danger">*</span></label>
                        <input type="number" step="0.1" min="0" max="10" name="calificacion" class="form-control grade-input shadow-sm" placeholder="0.0" required>
                    </div>
                </div>

                <div class="d-flex justify-content-end border-top pt-4 mt-2">
                    <a href="maestro_calificaciones.jsp" class="btn btn-light border me-3 fw-bold">Cancelar</a>
                    <button type="submit" class="btn-submit"><i class="bi bi-save me-2"></i>Guardar Calificación</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>