<%@page import="com.falyd.modelo.Tarea"%>
<%@page import="com.falyd.dao.TareaDAO"%>
<%@page import="com.falyd.modelo.Alumno"%>
<%@page import="com.falyd.dao.AlumnoDAO"%>
<%@page import="java.util.List"%>
<%@page import="com.falyd.modelo.Entrega"%>
<%@page import="com.falyd.dao.EntregaDAO"%>
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
            <a class="nav-link" href="maestro_recursos.jsp"><i class="bi bi-book me-2"></i> Recursos</a>
             <div class="mt-auto mb-4">
                <a class="nav-link text-danger" href="LogoutServlet"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>
            </div>
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
                
                <div class="row g-4 mb-4">
                    <div class="col-md-6">
                        <label class="form-label fw-bold small">Selecciona la Tarea / Actividad <span class="text-danger">*</span></label>
                        <select name="id_tarea" id="selectTarea" class="form-select" required onchange="actualizarEvidencia()">
                            <option value="" selected disabled>Elige la tarea a calificar...</option>
                            <%
                                // Variables obtenidas de la URL si la página se recargó
                                String tParam = request.getParameter("id_tarea");
                                String aParam = request.getParameter("id_alumno");
                                int idTareaActiva = (tParam != null && !tParam.isEmpty()) ? Integer.parseInt(tParam) : 0;
                                int idAlumnoACalificar = (aParam != null && !aParam.isEmpty()) ? Integer.parseInt(aParam) : 0;

                                TareaDAO tDAO = new TareaDAO();
                                List<Tarea> listaTareas = tDAO.listarTareasPorMaestro(user.getId_usuario());
                                for(Tarea t : listaTareas) {
                                    String selectedT = (t.getId_tarea() == idTareaActiva) ? "selected" : "";
                            %>
                                <option value="<%= t.getId_tarea() %>" <%= selectedT %>><%= t.getNombre_materia() %> - <%= t.getTitulo() %></option>
                            <% } %>
                        </select>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-bold small">Selecciona al Alumno <span class="text-danger">*</span></label>
                        <select name="id_alumno" id="selectAlumno" class="form-select" required onchange="actualizarEvidencia()">
                            <option value="" selected disabled>Elige al estudiante...</option>
                            <%
                                AlumnoDAO aDAO = new AlumnoDAO();
                                // Traemos todos los alumnos (puedes ajustar el método según tu DAO)
                                List<Alumno> listaAlumnos = aDAO.listarAlumnos(); 
                                for(Alumno a : listaAlumnos) {
                                    String selectedA = (a.getId_alumno() == idAlumnoACalificar) ? "selected" : "";
                            %>
                                <option value="<%= a.getId_alumno() %>" <%= selectedA %>><%= a.getNombre() %></option>
                            <% } %>
                        </select>
                    </div>
                </div>

                <%
                    if (idTareaActiva > 0 && idAlumnoACalificar > 0) {
                        EntregaDAO entregaDAO = new EntregaDAO();
                        Entrega tareaEnviada = entregaDAO.obtenerEntregaPorTareaYAlumno(idTareaActiva, idAlumnoACalificar);
                %>
                <div class="card p-4 border-0 shadow-sm rounded-4 mb-4 bg-white" style="border: 1px solid var(--border-color) !important;">
                    <h5 class="fw-bold text-dark mb-3"><i class="bi bi-file-earmark-arrow-up me-2 text-primary"></i>Evidencia de entrega</h5>
                    
                    <% if (tareaEnviada == null) { %>
                        <div class="alert alert-warning border-0 rounded-3 m-0 small d-flex align-items-center">
                            <i class="bi bi-exclamation-triangle-fill fs-5 me-3"></i>
                            <div>
                                <strong class="d-block">Sin entrega pendiente</strong>
                                El estudiante aún no ha subido ningún archivo para esta actividad.
                            </div>
                        </div>
                    <% } else { %>
                        <div class="p-3 bg-light rounded-3 border mb-3">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="badge bg-success rounded-pill px-3 py-1 text-white small">Archivo Recibido</span>
                                <span class="text-muted small fw-bold"><i class="bi bi-clock me-1"></i><%= tareaEnviada.getFecha_envio() %></span>
                            </div>
                            
                            <div class="bg-white p-3 rounded-3 border d-flex justify-content-between align-items-center">
                                <div class="d-flex align-items-center">
                                    <div class="me-3 fs-2 text-danger"><i class="bi bi-file-earmark-pdf-fill"></i></div>
                                    <div>
                                        <h6 class="fw-bold mb-0 text-dark text-truncate" style="max-width: 280px;">Documento de Evidencia</h6>
                                        <p class="text-muted small mb-0">Listo para evaluar</p>
                                    </div>
                                </div>
                                <a href="<%= tareaEnviada.getArchivo_url() %>" target="_blank" class="btn btn-sm fw-bold px-3 py-2 rounded-3 text-white" style="background-color: var(--blue-falyd);">
                                    <i class="bi bi-download me-2"></i>Descargar
                                </a>
                            </div>
                        </div>

                        <% if (tareaEnviada.getComentario_alumno() != null && !tareaEnviada.getComentario_alumno().trim().isEmpty()) { %>
                            <div class="mb-2">
                                <label class="fw-bold small text-muted mb-1">Nota adjunta del alumno:</label>
                                <p class="text-muted small bg-light p-3 rounded-3 border m-0" style="font-style: italic;">
                                    "<%= tareaEnviada.getComentario_alumno() %>"
                                </p>
                            </div>
                        <% } %>
                    <% } %>
                </div>
                <% } else { %>
                    <div class="text-center text-muted p-4 mb-4 border rounded-4 bg-light">
                        <i class="bi bi-hand-index-thumb fs-3"></i>
                        <p class="mt-2 small mb-0">Selecciona una tarea y un alumno para verificar si existe un archivo entregado.</p>
                    </div>
                <% } %>
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

            <script>
                function actualizarEvidencia() {
                    var tarea = document.getElementById("selectTarea").value;
                    var alumno = document.getElementById("selectAlumno").value;
                    if (tarea && alumno) {
                        // Recarga la página enviando los IDs por la URL para que Java los lea
                        window.location.href = "?id_tarea=" + tarea + "&id_alumno=" + alumno;
                    }
                }
            </script>
        </div>
    </div>
</body>
</html>