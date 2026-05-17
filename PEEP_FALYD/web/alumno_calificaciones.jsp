<%@page import="java.util.Locale"%>
<%@page import="com.falyd.modelo.Usuario"%>
<%@page import="com.falyd.modelo.Alumno"%>
<%@page import="com.falyd.dao.AlumnoDAO"%>
<%@page import="com.falyd.modelo.Materia"%>
<%@page import="com.falyd.dao.CalificacionDAO"%>
<%@page import="com.falyd.modelo.Tarea"%>
<%@page import="com.falyd.dao.TareaDAO"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.temporal.ChronoUnit"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");

    if (user == null || !user.getTipo_usuario().equals("ALUMNO")) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 1. Cargar datos del alumno
    AlumnoDAO aDAO = new AlumnoDAO();
    Alumno miPerfil = aDAO.obtenerAlumnoPorUsuario(user.getId_usuario());
    int idAlumnoReal = (miPerfil != null) ? miPerfil.getId_alumno() : 0;
    String nombreGrupo = (miPerfil != null && miPerfil.getGrupo() != null) ? miPerfil.getGrupo() : "Sin grupo";

    // 2. Cargar boleta de calificaciones reales de la Base de Datos
    CalificacionDAO calcDAO = new CalificacionDAO();
    List<Materia> boleta = calcDAO.obtenerBoletaAlumno(idAlumnoReal);

    // 3. Lógica para calcular las métricas superiores automáticamente
    double sumaPromedios = 0;
    int materiasAprobadas = 0;
    double mejorNota = 0;
    String mejorMateria = "Ninguna";

    for (Materia m : boleta) {
        sumaPromedios += m.getPromedio();
        if (m.getPromedio() >= 6.0) {
            materiasAprobadas++;
        }
        if (m.getPromedio() > mejorNota) {
            mejorNota = m.getPromedio();
            mejorMateria = m.getNombre_materia();
        }
    }

    double promedioGeneral = (boleta.isEmpty()) ? 0.0 : (sumaPromedios / boleta.size());

    // 4. Lógica de la Campanita de notificaciones
    TareaDAO tDAO = new TareaDAO();
List<Tarea> misTareas = tDAO.listarTareasPendientesPorAlumno(miPerfil.getId_alumno());
LocalDate hoy = LocalDate.now();
    List<Tarea> tareasPendientes = new ArrayList<>();
    for (Tarea t : misTareas) {
        if (t.getFecha_entrega() != null && !t.getFecha_entrega().isEmpty()) {
            if (ChronoUnit.DAYS.between(hoy, LocalDate.parse(t.getFecha_entrega())) >= 0) {
                tareasPendientes.add(t);
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Calificaciones - FALYD</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        :root { --blue-falyd: #0b3b60; --red-falyd: #d32f2f; --bg-light: #f4f7fe; --text-main: #2b3674; --border-color: #e2e8f0; }
        body { background-color: var(--bg-light); font-family: 'Segoe UI', sans-serif; color: var(--text-main); }
        .sidebar { width: 260px; height: 100vh; position: fixed; background: white; z-index: 100; border-right: 1px solid var(--border-color); }
        .sidebar-header { padding: 20px; text-align: center; border-bottom: 1px solid var(--border-color); margin-bottom: 15px; }
        .nav-link { color: #64748b; padding: 12px 25px; font-weight: 600; margin: 4px 15px; border-radius: 10px; transition: all 0.3s; text-decoration: none; display: block; }
        .nav-link i { font-size: 1.2rem; margin-right: 12px; }
        .nav-link:hover, .nav-link.active { background-color: #e3f2fd; color: var(--blue-falyd); }
        .main-content { margin-left: 260px; padding: 30px 40px; }
        
        .card-custom { background: white; border-radius: 20px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); border: 1px solid #f1f5f9; }
        
        /* Cajas de métricas */
        .metric-box { background: white; border-radius: 15px; padding: 20px; border: 1px solid var(--border-color); display: flex; align-items: center; }
        .metric-icon { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; margin-right: 15px; color: white; }
        
        /* Estilos de tabla */
        .table thead th { color: #8f9bba; font-weight: 600; font-size: 0.8rem; text-transform: uppercase; border-bottom: 2px solid var(--border-color); padding-bottom: 12px; }
        .table tbody tr { border-bottom: 1px solid #f1f5f9; }
        .table tbody td { padding: 15px 10px; vertical-align: middle; font-size: 0.95rem; }
        
        /* Badges de Desempeño idénticos a la imagen */
        .perf-badge { font-size: 0.8rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; display: inline-block; }
        .perf-excelente { background-color: #def7ec; color: #03543f; }
        .perf-muybueno { background-color: #e1effe; color: #1e429f; }
        .perf-bueno { background-color: #e3f2fd; color: #0d47a1; }
        .perf-suficiente { background-color: #fefcbf; color: #744210; }
        .perf-insuficiente { background-color: #fde8e8; color: #9b1c1c; }
        
        /* Escala de colores lateral */
        .scale-item { display: flex; align-items: center; justify-content: space-between; padding: 8px 0; border-bottom: 1px dashed var(--border-color); font-size: 0.85rem; }
        .scale-item:last-child { border-bottom: none; }
        .color-dot { width: 10px; height: 10px; border-radius: 50%; display: inline-block; margin-right: 8px; }
    </style>
</head>
<body>

    <div class="sidebar d-flex flex-column">
        <div class="sidebar-header">
            <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle mb-2" width="60">
            <h6 class="fw-bold mb-0 text-dark"><%= user.getNombre() %></h6>
            <p class="text-muted small mb-0">Grupo: <%= nombreGrupo %></p>
        </div>
        <nav class="nav flex-column flex-grow-1">
            <a class="nav-link" href="panel_alumno.jsp"><i class="bi bi-house-door-fill"></i> Inicio</a>
            <a class="nav-link" href="alumno_clases.jsp"><i class="bi bi-book-half"></i> Mis clases</a>
            <a class="nav-link" href="alumno_tareas.jsp"><i class="bi bi-check2-square"></i> Tareas</a>
            <a class="nav-link" href="alumno_calendario.jsp"><i class="bi bi-calendar3"></i> Calendario</a>
            <a class="nav-link" href="alumno_recursos.jsp"><i class="bi bi-folder2-open"></i> Recursos</a>
            <a class="nav-link active" href="alumno_calificaciones.jsp"><i class="bi bi-bar-chart-fill"></i> Calificaciones</a>
            
            <div class="mt-auto mb-4">
<a class="nav-link text-danger" href="#" data-bs-toggle="modal" data-bs-target="#modalCerrarSesion"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>            </div>
            </div>
        </nav>
    </div>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-5">
            <div>
                <h4 class="fw-bold mb-0" style="color: var(--blue-falyd);">Sistema Web Escolar</h4>
                <p class="text-muted small mb-0">Panel del Alumno</p>
            </div>
            <div class="d-flex align-items-center bg-white p-2 rounded-pill shadow-sm border">
                <div class="dropdown">
                    <button class="btn btn-link text-muted p-0 me-3 position-relative" data-bs-toggle="dropdown">
                        <i class="bi bi-bell-fill fs-5"></i>
                        <% if(!tareasPendientes.isEmpty()) { %>
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger border border-light" style="font-size: 0.65rem; padding: 4px 6px;">
                                <%= tareasPendientes.size() %>
                            </span>
                        <% } %>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0" style="width: 320px; border-radius: 15px; margin-top: 15px;">
                        <li><h6 class="dropdown-header fw-bold text-dark fs-6 border-bottom pb-2">Notificaciones</h6></li>
                        <% if(tareasPendientes.isEmpty()) { %>
                            <li><a class="dropdown-item py-3 small text-wrap text-muted text-center" href="#">No tienes tareas nuevas.</a></li>
                        <% } else { %>
                            <li><a class="dropdown-item py-3 small text-wrap text-muted" href="alumno_tareas.jsp"><i class="bi bi-journal-text me-2 text-primary"></i>Tienes <%= tareasPendientes.size() %> tareas pendientes.</a></li>
                        <% } %>
                    </ul>
                </div>

                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                <div class="me-2 lh-sm">
                    <p class="mb-0 fw-bold small"><%= user.getNombre() %></p>
                </div>
            </div>
        </div>

        <div class="mb-4">
            <h1 class="fw-bold mb-1">Calificaciones</h1>
            <p class="text-muted mb-0">Consulta tus calificaciones, promedios y tu desempeño académico.</p>
        </div>

        <div class="row g-3 mb-5">
            <div class="col-md-3">
                <div class="metric-box shadow-sm">
                    <div class="metric-icon" style="background-color: #10b981;"><i class="bi bi-graph-up-arrow"></i></div>
                    <div>
                        <h4 class="fw-bold mb-0 text-dark"><%= String.format(Locale.US, "%.1f", promedioGeneral) %></h4>
                        <p class="text-muted small mb-0 fw-semibold">Promedio general</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="metric-box shadow-sm">
                    <div class="metric-icon" style="background-color: #3b82f6;"><i class="bi bi-mortarboard-fill"></i></div>
                    <div>
                        <h4 class="fw-bold mb-0 text-dark"><%= materiasAprobadas %> <span class="text-muted fs-6">de <%= boleta.size() %></span></h4>
                        <p class="text-muted small mb-0 fw-semibold">Materias aprobadas</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="metric-box shadow-sm">
                    <div class="metric-icon" style="background-color: #8b5cf6;"><i class="bi bi-star-fill"></i></div>
                    <div>
                        <h4 class="fw-bold mb-0 text-dark text-truncate" style="max-width: 140px;"><%= String.format(Locale.US, "%.1f", mejorNota) %></h4>
                        <p class="text-muted small mb-0 fw-semibold text-truncate" style="max-width: 140px;"><%= mejorMateria %></p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="metric-box shadow-sm">
                    <div class="metric-icon" style="background-color: #f59e0b;"><i class="bi bi-bookmark-star"></i></div>
                    <div>
                        <h4 class="fw-bold mb-0 text-dark"><%= boleta.size() %></h4>
                        <p class="text-muted small mb-0 fw-semibold">Materias en curso</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-md-9">
                <div class="card-custom">
                    <ul class="nav nav-tabs border-bottom mb-4" style="gap: 15px;">
                        <li class="nav-item"><a class="nav-link active fw-bold text-primary border-0 border-bottom border-primary border-3" href="#">Vista general</a></li>
                        <li class="nav-item"><a class="nav-link text-muted fw-semibold border-0" href="#">Por periodo</a></li>
                        <li class="nav-item"><a class="nav-link text-muted fw-semibold border-0" href="#">Historial académico</a></li>
                    </ul>

                    <div class="table-responsive">
                        <table class="table table-borderless align-middle m-0">
                            <thead>
                                <tr>
                                    <th>Materia</th>
                                    <th>Profesor(a)</th>
                                    <th class="text-center">Calificación</th>
                                    <th class="text-center">Desempeño</th>
                                    <th class="text-center">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if(boleta.isEmpty()) { %>
                                    <tr><td colspan="5" class="text-center text-muted py-4">No tienes materias inscritas ni notas registradas.</td></tr>
                                <% } else { 
                                    for(Materia m : boleta) {
                                        double nota = m.getPromedio();
                                        String claseBadge = "perf-insuficiente"; String textoBadge = "Insuficiente";
                                        
                                        if (nota >= 9.0) { claseBadge = "perf-excelente"; textoBadge = "Excelente"; }
                                        else if (nota >= 8.0) { claseBadge = "perf-muybueno"; textoBadge = "Muy bueno"; }
                                        else if (nota >= 7.0) { claseBadge = "perf-bueno"; textoBadge = "Bueno"; }
                                        else if (nota >= 6.0) { claseBadge = "perf-suficiente"; textoBadge = "Suficiente"; }
                                %>
                                <tr>
                                    <td class="fw-bold text-dark"><%= m.getNombre_materia() %></td>
                                    <td class="text-muted"><%= m.getNombre_maestro() %></td>
                                    <td class="text-center fw-bold text-primary fs-5"><%= nota > 0 ? String.format(Locale.US, "%.1f", nota) : "N/A" %></td>
                                    <td class="text-center"><span class="perf-badge <%= claseBadge %>"><%= textoBadge %></span></td>
                                    <td class="text-center"><button class="btn btn-sm btn-light border fw-bold text-muted rounded-3 px-3">Ver detalle</button></td>
                                </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col-md-3">
                <div class="card-custom">
                    <h6 class="fw-bold mb-3 text-dark">Escala de evaluación</h6>
                    <div class="scale-item"><span class="small text-muted"><span class="color-dot" style="background-color: #10b981;"></span>9.0 - 10</span> <span class="badge perf-excelente small">Excelente</span></div>
                    <div class="scale-item"><span class="small text-muted"><span class="color-dot" style="background-color: #3b82f6;"></span>8.0 - 8.9</span> <span class="badge perf-muybueno small">Muy bueno</span></div>
                    <div class="scale-item"><span class="small text-muted"><span class="color-dot" style="background-color: #0d47a1;"></span>7.0 - 7.9</span> <span class="badge perf-bueno small">Bueno</span></div>
                    <div class="scale-item"><span class="small text-muted"><span class="color-dot" style="background-color: #f59e0b;"></span>6.0 - 6.9</span> <span class="badge perf-suficiente small">Suficiente</span></div>
                    <div class="scale-item"><span class="small text-muted"><span class="color-dot" style="background-color: #ef4444;"></span>Menos de 6.0</span> <span class="badge perf-insuficiente small">Insuficiente</span></div>
                </div>
            </div>
        </div>
    </div>
<div class="modal fade" id="modalCerrarSesion" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" style="max-width: 380px;">
            <div class="modal-content border-0 shadow" style="border-radius: 20px;">
                <div class="modal-body text-center p-4">
                    <div class="mx-auto mb-3 d-flex align-items-center justify-content-center" style="width: 75px; height: 75px; background-color: #fee2e2; border-radius: 50%; color: #ef4444; font-size: 2.2rem;">
                        <i class="bi bi-box-arrow-right"></i>
                    </div>
                    
                    <h4 class="fw-bold mb-2" style="color: var(--text-main);">¿Cerrar sesión?</h4>
                    <p class="text-muted small mb-4 px-2">Estás a punto de cerrar sesión en el sistema. Tendrás que ingresar tus credenciales nuevamente para acceder.</p>
                    
                    <div class="d-flex justify-content-center gap-3">
                        <button type="button" class="btn fw-bold px-4 py-2 flex-grow-1" data-bs-dismiss="modal" style="border: 1px solid var(--border-color); color: var(--blue-falyd); border-radius: 10px; background: white;">Cancelar</button>
                        <a href="LogoutServlet" class="btn btn-danger fw-bold px-4 py-2 flex-grow-1" style="border-radius: 10px; background-color: #e53e3e; border: none;">Cerrar sesión</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>