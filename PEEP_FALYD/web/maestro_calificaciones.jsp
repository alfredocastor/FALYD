<%@page import="com.falyd.dao.CalificacionDAO"%>
<%@page import="com.falyd.modelo.Alumno"%>
<%@page import="com.falyd.dao.AlumnoDAO"%>
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

    // Capturar la materia seleccionada por el filtro
    String idMateriaStr = request.getParameter("id_materia");
    int idMateriaSeleccionada = 0;
    if (idMateriaStr != null && !idMateriaStr.isEmpty()) {
        idMateriaSeleccionada = Integer.parseInt(idMateriaStr);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calificaciones - Panel del Maestro</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root { --blue-falyd: #0b3b60; --red-falyd: #d32f2f; --bg-light: #f4f7fe; --text-main: #2b3674; --border-color: #e2e8f0; }
        body { background-color: var(--bg-light); font-family: 'Segoe UI', sans-serif; color: var(--text-main); }
        .sidebar { width: 260px; height: 100vh; position: fixed; background: white; border-right: none; box-shadow: 2px 0 20px rgba(0,0,0,0.04); z-index: 100; border-bottom-right-radius: 50px; }
        .nav-link { color: #8f9bba; padding: 12px 25px; font-weight: 600; margin: 4px 15px; border-radius: 10px; transition: all 0.3s; }
        .nav-link i { font-size: 1.2rem; margin-right: 12px; }
        .nav-link:hover, .nav-link.active { background-color: #e3f2fd; color: var(--blue-falyd); }
        .main-content { margin-left: 260px; padding: 30px 40px; }
        .card-custom { background: white; border-radius: 20px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); border: none; height: 100%; }
        .table thead th { border-bottom: 2px solid var(--border-color); color: #8f9bba; font-weight: 600; font-size: 0.8rem; padding-bottom: 15px; text-transform: uppercase; text-align: center; }
        .table thead th:first-child, .table thead th:nth-child(2) { text-align: left; }
        .table tbody td { vertical-align: middle; padding: 12px 10px; border-bottom: 1px solid #f1f5f9; color: var(--text-main); font-weight: 600; font-size: 0.95rem; text-align: center; }
        .table tbody td:first-child, .table tbody td:nth-child(2) { text-align: left; }
        .table tbody tr:hover { background-color: #f8fafc; }
        .avatar-img { width: 35px; height: 35px; border-radius: 50%; object-fit: cover; margin-right: 10px; }
        .stat-value { font-size: 2.5rem; font-weight: 700; color: #38a169; line-height: 1; }
        .stat-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #f1f5f9; font-size: 0.9rem; }
        .btn-icon { background: #f8fafc; border: 1px solid var(--border-color); color: var(--blue-falyd); width: 32px; height: 32px; border-radius: 8px; display: inline-flex; align-items: center; justify-content: center; text-decoration: none; font-size: 0.8rem; }
        .btn-icon:hover { background: #e3f2fd; border-color: #bbdefb; }
        .grade-excellent { color: #38a169; }
        .grade-good { color: var(--blue-falyd); }
        .grade-warning { color: #d69e2e; }
        .grade-danger { color: var(--red-falyd); }
    </style>
</head>
<body>

    <div class="sidebar d-flex flex-column">
        <div class="p-4 text-center"><img src="img/Logo.png" style="width: 120px; margin-bottom: 5px;"></div>
        <nav class="nav flex-column mt-2 flex-grow-1">
            <a class="nav-link" href="panel_maestro.jsp"><i class="bi bi-house-door-fill"></i> Inicio</a>
            <a class="nav-link" href="maestro_tareas.jsp"><i class="bi bi-check2-square"></i> Tareas</a>
            <a class="nav-link" href="maestro_calendario.jsp"><i class="bi bi-calendar3"></i> Calendario</a>
            <a class="nav-link" href="maestro_alumnos.jsp"><i class="bi bi-people-fill"></i> Alumnos</a>
            <a class="nav-link active" href="maestro_calificaciones.jsp"><i class="bi bi-clipboard-data"></i> Calificaciones</a>
            <a class="nav-link" href="maestro_recursos.jsp"><i class="bi bi-book"></i> Recursos</a>
             <div class="mt-auto mb-4">
                <a class="nav-link text-danger" href="LogoutServlet"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>
            </div>
        </nav>
    </div>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-5">
            <div>
                <h4 class="fw-bold mb-0" style="color: var(--blue-falyd);">Sistema Web Escolar</h4>
                <h5 class="fw-bold mb-0" style="color: var(--red-falyd);">Luis Moya</h5>
                <p class="text-muted small mb-0">Panel del Maestro</p>
            </div>
            <div class="d-flex align-items-center bg-white p-2 rounded-pill shadow-sm">
                 <div class="dropdown">
                    <button class="btn btn-link text-muted p-0 me-3 position-relative" data-bs-toggle="dropdown">
                        <i class="bi bi-bell-fill fs-5"></i>
                        <span class="position-absolute top-0 start-100 translate-middle p-1 bg-danger border border-light rounded-circle"></span>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow border-0" style="width: 320px; border-radius: 15px; margin-top: 15px;">
                        <li><h6 class="dropdown-header fw-bold text-dark fs-6 border-bottom pb-2">Notificaciones</h6></li>
                        <li><a class="dropdown-item py-3 border-bottom small text-wrap" href="maestro_calificaciones.jsp"><i class="bi bi-info-circle-fill text-primary me-2"></i>Recuerda calificar las tareas.</a></li>
                    </ul>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                <div class="me-3 lh-sm">
                    <p class="mb-0 fw-bold small"><%= user.getNombre() %></p>
                    <p class="mb-0 text-muted" style="font-size: 0.75rem;">Maestro</p>
                </div>
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-end mb-4">
            <div>
                <h1 class="fw-bold mb-1">Calificaciones</h1>
                <p class="text-muted mb-0">Consulta, registra y gestiona las calificaciones de tus alumnos.</p>
            </div>
            <a href="maestro_registrar_calificacion.jsp" class="btn btn-primary text-decoration-none" style="background-color: var(--blue-falyd); border-radius: 10px; font-weight: 600; padding: 10px 20px;">
                <i class="bi bi-plus-lg me-2"></i>Registrar calificación
            </a>
            
        </div>
        

        <div class="row g-3 mb-4 d-flex align-items-end">
            <div class="col-md-4">
                <label class="form-label text-muted small fw-bold mb-1">Filtrar por Materia:</label>
                <select class="form-select border-light shadow-sm text-muted fw-bold" onchange="location.href='maestro_calificaciones.jsp?id_materia=' + this.value;">
                    <option value="" <%= (idMateriaSeleccionada == 0) ? "selected" : "" %> disabled>Selecciona una materia...</option>
                    <%
                        MateriaDAO matDAO = new MateriaDAO();
                        List<Materia> misMaterias = matDAO.listarMateriasPorMaestro(user.getId_usuario());
                        for(Materia m : misMaterias) {
                    %>
                        <option value="<%= m.getId_materia() %>" <%= (m.getId_materia() == idMateriaSeleccionada) ? "selected" : "" %>><%= m.getNombre_materia() %></option>
                    <% } %>
                </select>
                
            </div>
                <div class="col-md-5 text-end">
                <% if (idMateriaSeleccionada > 0) { %>
                    <a href="ReporteServlet?tipo=calificaciones&id_materia=<%= idMateriaSeleccionada %>" class="btn btn-outline-primary fw-bold px-4" style="border-radius: 10px;">
                        <i class="bi bi-download me-2"></i> Exportar PDF
                    </a>
                <% } else { %>
                    <button type="button" onclick="alert('Por favor, selecciona una materia en el filtro antes de exportar el reporte.');" class="btn btn-outline-secondary fw-bold px-4" style="border-radius: 10px;">
                        <i class="bi bi-download me-2"></i> Exportar PDF
                    </button>
                <% } %>
            </div>
                
        </div>
                

        <div class="row g-4">
            <div class="col-md-8">
                <div class="card-custom">
                    <h5 class="fw-bold mb-4">Lista de Rendimiento Académico</h5>
                    
                    <div class="table-responsive">
                        <table class="table table-borderless align-middle">
                            <thead>
                                <tr>
                                    <th style="width: 5%;">#</th>
                                    <th style="width: 45%;">Alumno</th>
                                    <th style="width: 25%;">Tareas Evaluadas</th>
                                    <th style="width: 25%;">Promedio General</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    AlumnoDAO aDAO = new AlumnoDAO();
                                    CalificacionDAO cDAO = new CalificacionDAO();
                                    List<Alumno> listaAlumnos = aDAO.listarAlumnos();
                                    
                                    int contador = 1;
                                    double sumaPromedios = 0;
                                    double notaAlta = 0;
                                    double notaBaja = 10;
                                    int aprobados = 0;
                                    int enRiesgo = 0;
                                    int alumnosConNota = 0;
                                    
                                    // Contadores para la gráfica
                                    int catExcelente = 0, catBueno = 0, catRegular = 0, catInsuficiente = 0;

                                    if (idMateriaSeleccionada == 0) {
                                %>
                                    <tr><td colspan="4" class="text-center py-4 text-muted">Por favor, selecciona una materia arriba para calcular los promedios.</td></tr>
                                <%
                                    } else if (listaAlumnos.isEmpty()) {
                                %>
                                    <tr><td colspan="4" class="text-center py-4 text-muted">No hay alumnos registrados.</td></tr>
                                <%
                                    } else {
                                        for (Alumno a : listaAlumnos) {
                                            double promedio = cDAO.obtenerPromedioAlumnoMateria(a.getId_alumno(), idMateriaSeleccionada);
                                            int tareasCalificadas = cDAO.contarTareasCalificadas(a.getId_alumno(), idMateriaSeleccionada);
                                            
                                            String promedioMostrar = "---";
                                            String claseColor = "text-muted";
                                            
                                            if (promedio >= 0) {
                                                alumnosConNota++;
                                                sumaPromedios += promedio;
                                                if (promedio > notaAlta) notaAlta = promedio;
                                                if (promedio < notaBaja) notaBaja = promedio;
                                                if (promedio >= 6.0) aprobados++; else enRiesgo++;
                                                
                                                promedioMostrar = String.format("%.2f", promedio);
                                                
                                                if (promedio >= 9.0) { claseColor = "grade-excellent"; catExcelente++; }
                                                else if (promedio >= 8.0) { claseColor = "grade-good"; catBueno++; }
                                                else if (promedio >= 6.0) { claseColor = "grade-warning"; catRegular++; }
                                                else { claseColor = "grade-danger"; catInsuficiente++; }
                                            }
                                %>
                                    <tr>
                                        <td class="text-muted"><%= contador %></td>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <img src="https://ui-avatars.com/api/?name=<%= a.getNombre() %>&background=random&color=fff" class="avatar-img">
                                                <span class="fw-bold"><%= a.getNombre() %></span>
                                            </div>
                                        </td>
                                        <td><span class="badge bg-light text-dark border p-2"><%= tareasCalificadas %> tareas</span></td>
                                        <td class="<%= claseColor %> fs-5 fw-bold"><%= promedioMostrar %></td>
                                    </tr>
                                <%
                                            contador++;
                                        }
                                    }
                                    
                                    // Ajustar nota baja por si ningún alumno tiene notas registradas
                                    if(alumnosConNota == 0) { notaBaja = 0.0; }
                                    double promedioGeneralGrupo = (alumnosConNota > 0) ? (sumaPromedios / alumnosConNota) : 0.0;
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card-custom mb-4" style="height: auto;">
                    <h6 class="fw-bold mb-3">Resumen real del grupo</h6>
                    <p class="text-muted small mb-1">Promedio general de materia</p>
                    <div class="stat-value mb-4"><%= String.format("%.2f", promedioGeneralGrupo) %></div>
                    
                    <div class="stat-row"><span class="text-muted">Calificación más alta</span><span class="fw-bold text-success"><%= String.format("%.2f", notaAlta) %></span></div>
                    <div class="stat-row"><span class="text-muted">Calificación más baja</span><span class="fw-bold text-danger"><%= String.format("%.2f", notaBaja) %></span></div>
                    <div class="stat-row"><span class="text-muted">Alumnos aprobados (Nota &ge; 6.0)</span><span class="fw-bold text-primary"><%= aprobados %></span></div>
                    <div class="stat-row"><span class="text-muted">Alumnos reprobados / En riesgo</span><span class="fw-bold text-danger"><%= enRiesgo %></span></div>
                </div>

                <div class="card-custom" style="height: auto;">
                    <h6 class="fw-bold mb-3">Distribución de calificaciones</h6>
                    <div style="position: relative; height: 180px; width: 100%; display: flex; justify-content: center;">
                        <canvas id="graficaPastel"></canvas>
                    </div>
                    <div class="mt-4 small">
                        <p class="mb-1"><i class="bi bi-circle-fill text-success me-2"></i>Excelente (9 - 10) <span class="float-end fw-bold"><%= catExcelente %> alumnos</span></p>
                        <p class="mb-1"><i class="bi bi-circle-fill text-primary me-2"></i>Bueno (8 - 8.9) <span class="float-end fw-bold"><%= catBueno %> alumnos</span></p>
                        <p class="mb-1"><i class="bi bi-circle-fill text-warning me-2"></i>Regular (6 - 7.9) <span class="float-end fw-bold"><%= catRegular %> alumnos</span></p>
                        <p class="mb-0"><i class="bi bi-circle-fill text-danger me-2"></i>Insuficiente (0 - 5.9) <span class="float-end fw-bold"><%= catInsuficiente %> alumnos</span></p>
                    </div>
                </div>
            </div>
        </div>
    </div>
                            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        const ctx = document.getElementById('graficaPastel').getContext('2d');
        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Excelente', 'Bueno', 'Regular', 'Insuficiente'],
                datasets: [{
                    data: [<%= catExcelente %>, <%= catBueno %>, <%= catRegular %>, <%= catInsuficiente %>],
                    backgroundColor: ['#38a169', '#0d47a1', '#d69e2e', '#e53e3e'],
                    borderWidth: 0,
                    cutout: '70%'
                }]
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } } }
        });
    </script>
</body>
</html>