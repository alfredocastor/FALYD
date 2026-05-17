<%@page import="com.falyd.modelo.Materia"%>
<%@page import="com.falyd.dao.MateriaDAO"%>
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
    <title>Crear Evento - FALYD</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        :root { --blue-falyd: #0b3b60; --red-falyd: #d32f2f; --bg-light: #f4f7fe; --text-main: #2b3674; --border-color: #e2e8f0; }
        body { background-color: var(--bg-light); font-family: 'Segoe UI', sans-serif; color: var(--text-main); }
        .sidebar { width: 260px; height: 100vh; position: fixed; background: white; z-index: 100; border-bottom-right-radius: 50px; }
        .nav-link { color: #8f9bba; padding: 12px 25px; font-weight: 600; margin: 4px 15px; border-radius: 10px; display:block; text-decoration:none;}
        .nav-link:hover, .nav-link.active { background-color: #e3f2fd; color: var(--blue-falyd); }
        .main-content { margin-left: 260px; padding: 30px 40px; padding-bottom: 80px;}
        .form-container { background: white; border-radius: 20px; padding: 40px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); }
        .form-label { font-weight: 600; font-size: 0.9rem; color: var(--text-main); margin-bottom: 8px; }
        .form-control, .form-select { border-radius: 10px; border: 1px solid var(--border-color); padding: 10px 15px; }
        .btn-submit { background: var(--blue-falyd); border: none; color: white; font-weight: 600; border-radius: 10px; padding: 10px 25px; }
        .color-dot { width: 25px; height: 25px; border-radius: 50%; display: inline-block; cursor: pointer; margin-right: 10px; border: 2px solid transparent;}
        .color-radio { display: none; }
        .color-radio:checked + .color-dot { border-color: #2b3674; transform: scale(1.1); }
    </style>
</head>
<body>

    <div class="sidebar d-flex flex-column">
        <div class="p-4 text-center"><img src="img/Logo.png" width="120"></div>
        <nav class="nav flex-column mt-2 flex-grow-1">
            <a class="nav-link" href="panel_maestro.jsp"><i class="bi bi-house-door-fill me-2"></i> Inicio</a>
            <a class="nav-link" href="maestro_tareas.jsp"><i class="bi bi-check2-square me-2"></i> Tareas</a>
            <a class="nav-link active" href="maestro_calendario.jsp"><i class="bi bi-calendar3 me-2"></i> Calendario</a>
            <a class="nav-link" href="maestro_alumnos.jsp"><i class="bi bi-people-fill me-2"></i> Alumnos</a>
            <a class="nav-link" href="maestro_calificaciones.jsp"><i class="bi bi-clipboard-data me-2"></i> Calificaciones</a>
            <a class="nav-link" href="maestro_recursos.jsp"><i class="bi bi-book me-2"></i> Recursos</a>
        </nav>
    </div>

    <div class="main-content">
        <div class="mb-4">
            <a href="maestro_calendario.jsp" class="text-decoration-none fw-bold text-muted">
                <i class="bi bi-arrow-left me-1"></i> Calendario / <span style="color: var(--blue-falyd);">Crear evento</span>
            </a>
        </div>

        <div class="form-container">
            <div class="d-flex align-items-center mb-5">
                <div class="me-3" style="font-size: 2.5rem; color: var(--blue-falyd);"><i class="bi bi-calendar-plus"></i></div>
                <div>
                    <h2 class="fw-bold mb-1">Crear nuevo evento</h2>
                    <p class="text-muted mb-0">Completa la información para agregar una actividad al calendario escolar.</p>
                </div>
            </div>

            <form action="EventoServlet" method="POST">
                <input type="hidden" name="accion" value="crear">
                <input type="hidden" name="id_usuario_maestro" value="<%= user.getId_usuario() %>">

                <h5 class="fw-bold border-bottom pb-2 mb-4">1. Información del evento</h5>
                <div class="row g-4 mb-5">
                    <div class="col-md-6">
                        <label class="form-label">Título del evento *</label>
                        <input type="text" name="titulo" class="form-control" placeholder="Ej. Reunión de padres de familia" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Tipo de evento *</label>
                        <select name="tipo_evento" class="form-select" required>
                            <option value="Clases">Clase oficial</option>
                            <option value="Evaluaciones">Evaluación / Examen</option>
                            <option value="Entregas de tareas">Entrega de tareas</option>
                            <option value="Reuniones">Reunión escolar</option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Vincular a Materia (Opcional)</label>
                        <select name="id_materia" class="form-select">
                            <option value="">Ninguna / Evento General</option>
                            <%
                                MateriaDAO matDAO = new MateriaDAO();
                                List<Materia> misMaterias = matDAO.listarMateriasPorMaestro(user.getId_usuario());
                                for(Materia m : misMaterias) {
                            %>
                                <option value="<%= m.getId_materia() %>"><%= m.getNombre_materia() %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label d-block">Color del evento *</label>
                        <div class="pt-2">
                            <input type="radio" name="color" value="#0d47a1" id="c1" class="color-radio" checked>
                            <label for="c1" class="color-dot" style="background-color: #0d47a1;"></label>
                            
                            <input type="radio" name="color" value="#c53929" id="c2" class="color-radio">
                            <label for="c2" class="color-dot" style="background-color: #c53929;"></label>
                            
                            <input type="radio" name="color" value="#137333" id="c3" class="color-radio">
                            <label for="c3" class="color-dot" style="background-color: #137333;"></label>
                            
                            <input type="radio" name="color" value="#d69e2e" id="c4" class="color-radio">
                            <label for="c4" class="color-dot" style="background-color: #d69e2e;"></label>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <label class="form-label">Descripción</label>
                        <textarea name="descripcion" class="form-control" rows="3" placeholder="Escribe los detalles del evento..."></textarea>
                    </div>
                </div>

                <h5 class="fw-bold border-bottom pb-2 mb-4">2. Fecha y hora</h5>
                <div class="row g-4 mb-5">
                    <div class="col-md-3">
                        <label class="form-label">Fecha de inicio *</label>
                        <input type="date" name="fecha_inicio" class="form-control" required>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Hora de inicio</label>
                        <input type="time" name="hora_inicio" class="form-control">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Fecha de fin (Opcional)</label>
                        <input type="date" name="fecha_fin" class="form-control">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Hora de fin (Opcional)</label>
                        <input type="time" name="hora_fin" class="form-control">
                    </div>
                    <div class="col-md-12">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="todo_el_dia" id="allDay">
                            <label class="form-check-label fw-bold" for="allDay">Marcar si el evento dura todo el día</label>
                        </div>
                    </div>
                </div>

                <div class="d-flex justify-content-end border-top pt-4">
                    <a href="maestro_calendario.jsp" class="btn btn-light border me-3 fw-bold">Cancelar</a>
                    <button type="submit" class="btn btn-submit"><i class="bi bi-save me-2"></i>Crear evento</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>