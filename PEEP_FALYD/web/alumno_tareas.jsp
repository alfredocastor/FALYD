<%@page import="com.falyd.modelo.Usuario"%>
<%@page import="com.falyd.modelo.Alumno"%>
<%@page import="com.falyd.dao.AlumnoDAO"%>
<%@page import="com.falyd.modelo.Tarea"%>
<%@page import="com.falyd.dao.TareaDAO"%>
<%@page import="com.falyd.modelo.Materia"%>
<%@page import="com.falyd.dao.MateriaDAO"%>
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

    // 1. Obtener datos del alumno
    AlumnoDAO aDAO = new AlumnoDAO();
    Alumno miPerfil = aDAO.obtenerAlumnoPorUsuario(user.getId_usuario());

    // 2. Traer AMBAS listas de la Base de Datos
    TareaDAO tDAO = new TareaDAO();
    List<Tarea> todasLasTareas = tDAO.listarTareasParaAlumno(); 
    List<Tarea> tareasPendientesBD = tDAO.listarTareasPendientesPorAlumno(miPerfil.getId_alumno());
    
    // Obtener materias para el filtro
    MateriaDAO mDAO = new MateriaDAO();
    List<Materia> misMaterias = mDAO.listarMateriasGenerales();

    // 3. Lógica matemática de listas
    LocalDate hoy = LocalDate.now();
    List<Tarea> tareasPendientes = new ArrayList<>();
    List<Tarea> tareasAtrasadas = new ArrayList<>();
    List<Tarea> tareasEntregadas = new ArrayList<>();
    int proximas = 0;

    // A) Clasificamos las pendientes y atrasadas (Las que devolvió la BD como no calificadas)
    for (Tarea t : tareasPendientesBD) {
        if (t.getFecha_entrega() != null && !t.getFecha_entrega().isEmpty()) {
            LocalDate fechaEntrega = LocalDate.parse(t.getFecha_entrega());
            long diasRestantes = ChronoUnit.DAYS.between(hoy, fechaEntrega);

            if (diasRestantes < 0) {
                tareasAtrasadas.add(t); // Vencida
            } else {
                tareasPendientes.add(t); // Aún hay tiempo
                if (diasRestantes <= 7) proximas++; // Vence en 7 días
            }
        }
    }
    
    // B) Calculamos las entregadas/calificadas (Están en todasLasTareas pero NO en tareasPendientesBD)
    for (Tarea t : todasLasTareas) {
        boolean esPendiente = false;
        for(Tarea p : tareasPendientesBD) {
            if(p.getId_tarea() == t.getId_tarea()) {
                esPendiente = true; break;
            }
        }
        if(!esPendiente) {
            tareasEntregadas.add(t); // Esta ya fue calificada
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Tareas - Panel del Alumno</title>
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
        
        .stat-card { border: 1px solid var(--border-color); border-radius: 15px; padding: 20px; display: flex; align-items: center; background: white; transition: 0.2s; height: 100%; }
        .stat-card:hover { transform: translateY(-3px); box-shadow: 0 5px 15px rgba(0,0,0,0.03); }
        .stat-icon { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; margin-right: 15px; }
        
        .task-list-item { padding: 20px; border: 1px solid var(--border-color); border-radius: 15px; margin-bottom: 15px; transition: 0.2s; background: white; }
        .task-list-item:hover { border-color: #cbd5e1; box-shadow: 0 4px 10px rgba(0,0,0,0.02); }
        .task-icon-large { width: 60px; height: 60px; border-radius: 15px; display: flex; align-items: center; justify-content: center; font-size: 2rem; color: white; margin-right: 20px; }
        
        .btn-ver { color: var(--blue-falyd); border: 1px solid var(--border-color); border-radius: 8px; font-weight: 600; padding: 6px 15px; background: transparent; transition: 0.2s; text-decoration: none;}
        .btn-ver:hover { opacity: 0.8; color: white; }
        .priority-badge { font-size: 0.75rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; }
        .prio-alta { color: #dc3545; background: #ffebee; }
        .prio-media { color: #d69e2e; background: #fefcbf; }
        .prio-baja { color: #38a169; background: #c6f6d5; }
    </style>
</head>
<body>

    <div class="sidebar d-flex flex-column">
        <div class="sidebar-header">
            <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle mb-2" width="60">
            <h6 class="fw-bold mb-0 text-dark"><%= user.getNombre() %></h6>
            <p class="text-muted small mb-0">Alumno</p>
        </div>
        <nav class="nav flex-column flex-grow-1">
            <a class="nav-link" href="panel_alumno.jsp"><i class="bi bi-house-door-fill"></i> Inicio</a>
            <a class="nav-link" href="alumno_clases.jsp"><i class="bi bi-book-half"></i> Mis clases</a>
            <a class="nav-link active" href="alumno_tareas.jsp"><i class="bi bi-check2-square"></i> Tareas</a>
            <a class="nav-link" href="alumno_calendario.jsp"><i class="bi bi-calendar3"></i> Calendario</a>
            <a class="nav-link" href="alumno_recursos.jsp"><i class="bi bi-folder2-open"></i> Recursos</a>
            <a class="nav-link" href="alumno_calificaciones.jsp"><i class="bi bi-bar-chart-fill"></i> Calificaciones</a>
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
                        <% if(tareasPendientesBD.size() > 0) { %>
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger border border-light" style="font-size: 0.65rem; padding: 4px 6px;">
                                <%= tareasPendientesBD.size() %>
                            </span>
                        <% } %>
                    </button>
                </div>
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                <div class="me-2 lh-sm">
                    <p class="mb-0 fw-bold small"><%= user.getNombre() %></p>
                </div>
            </div>
        </div>

        <div class="mb-4">
            <h1 class="fw-bold mb-1">Mis tareas</h1>
            <p class="text-muted mb-0">Consulta tus tareas pendientes, entregadas y próximas.</p>
        </div>

        <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
            <ul class="nav nav-pills" id="tabsTareas" style="gap: 10px;">
                <li class="nav-item">
                    <a class="nav-link active rounded-pill px-4" href="#" onclick="cambiarPestana('pendientes', this); return false;" style="background-color: var(--blue-falyd); color: white;">
                        Pendientes <span class="badge bg-white text-dark ms-2"><%= tareasPendientes.size() + tareasAtrasadas.size() %></span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-muted fw-bold rounded-pill px-4" href="#" onclick="cambiarPestana('entregadas', this); return false;">
                        Entregadas <span class="badge bg-light text-muted ms-2 border"><%= tareasEntregadas.size() %></span>
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-muted fw-bold rounded-pill px-4" href="#" onclick="cambiarPestana('todas', this); return false;">
                        Todas <span class="badge bg-light text-muted ms-2 border"><%= todasLasTareas.size() %></span>
                    </a>
                </li>
            </ul>
            
            <div class="input-group w-auto">
                <span class="input-group-text bg-white border-end-0 text-muted rounded-start-pill"><i class="bi bi-filter"></i></span>
                <select id="filtroMateria" class="form-select border-start-0 rounded-end-pill text-muted fw-bold" style="width: 200px;" onchange="aplicarFiltros()">
                    <option value="todas" selected>Todas las materias</option>
                    <% for(Materia m : misMaterias) { %>
                        <option value="<%= m.getNombre_materia() %>"><%= m.getNombre_materia() %></option>
                    <% } %>
                </select>
            </div>
        </div>

        <div class="row g-4 mb-5">
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon" style="background-color: #fff8e1; color: #f59e0b;"><i class="bi bi-clipboard"></i></div>
                    <div><h4 class="fw-bold mb-0 text-dark"><%= tareasPendientes.size() %></h4><p class="text-muted small mb-0 lh-sm">Por entregar</p></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon" style="background-color: #e8f5e9; color: #10b981;"><i class="bi bi-check-circle"></i></div>
                    <div><h4 class="fw-bold mb-0 text-dark"><%= tareasEntregadas.size() %></h4><p class="text-muted small mb-0 lh-sm">Completadas</p></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon" style="background-color: #f3e5f5; color: #8b5cf6;"><i class="bi bi-clock-history"></i></div>
                    <div><h4 class="fw-bold mb-0 text-dark"><%= proximas %></h4><p class="text-muted small mb-0 lh-sm">Próximos 7 días</p></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card" style="<%= (tareasAtrasadas.size() > 0) ? "border-color: #fca5a5; background-color: #fef2f2;" : "" %>">
                    <div class="stat-icon" style="background-color: #ffebee; color: #ef4444;"><i class="bi bi-calendar-x"></i></div>
                    <div><h4 class="fw-bold mb-0 <%= (tareasAtrasadas.size() > 0) ? "text-danger" : "text-dark" %>"><%= tareasAtrasadas.size() %></h4><p class="<%= (tareasAtrasadas.size() > 0) ? "text-danger" : "text-muted" %> small mb-0 lh-sm">Vencidas</p></div>
                </div>
            </div>
        </div>

        <div class="card-custom">
            <h5 class="fw-bold mb-4 pb-2 border-bottom">Lista de tareas</h5>

            <div id="contenedorTareas">
                <% 
                String[] bgColors = {"#3b82f6", "#ef4444", "#10b981", "#f59e0b"};
                String[] icons = {"bi-journal-text", "bi-book", "bi-pencil-square", "bi-flask"};
                int index = 0;
                
                for (Tarea t : tareasPendientes) {
                    LocalDate f = LocalDate.parse(t.getFecha_entrega());
                    long dias = ChronoUnit.DAYS.between(hoy, f);
                    String prioTexto = "Baja"; String cPrio = "prio-baja";
                    if(dias <= 2) { prioTexto = "Alta"; cPrio = "prio-alta"; } else if (dias <= 5) { prioTexto = "Media"; cPrio = "prio-media"; }
                %>
                <div class="task-list-item d-flex align-items-center" data-estado="pendientes" data-materia="<%= t.getNombre_materia() %>">
                    <div class="task-icon-large shadow-sm" style="background-color: <%= bgColors[index % 4] %>;"><i class="bi <%= icons[index % 4] %>"></i></div>
                    <div class="flex-grow-1 border-end pe-4 me-4">
                        <h5 class="fw-bold mb-1 text-dark"><%= t.getTitulo() %></h5><p class="text-muted small mb-1"><%= t.getNombre_materia() %> • <%= t.getDescripcion() %></p>
                    </div>
                    <div class="text-center border-end pe-4 me-4" style="width: 150px;">
                        <p class="mb-0 fw-bold text-dark"><i class="bi bi-calendar-event me-2"></i><%= t.getFecha_entrega() %></p>
                        <p class="mb-0 small text-danger fw-bold">(<%= dias %> días restantes)</p>
                    </div>
                    <div class="text-center border-end pe-4 me-4" style="width: 100px;"><span class="priority-badge <%= cPrio %>"><%= prioTexto %></span></div>
                    <div class="text-center" style="width: 120px;"><a href="alumno_entregar_tarea.jsp?id_tarea=<%= t.getId_tarea() %>" class="btn-ver w-100 d-block" style="background-color: var(--blue-falyd); color: white;">Entregar</a></div>
                </div>
                <% index++; } %>

                <% for (Tarea t : tareasAtrasadas) { 
                    long dias = ChronoUnit.DAYS.between(LocalDate.parse(t.getFecha_entrega()), hoy); 
                %>
                <div class="task-list-item d-flex align-items-center" data-estado="pendientes" data-materia="<%= t.getNombre_materia() %>" style="background-color: #fff5f5; border-color: #fed7d7;">
                    <div class="task-icon-large shadow-sm" style="background-color: #ef4444;"><i class="bi bi-exclamation-triangle"></i></div>
                    <div class="flex-grow-1 border-end border-danger pe-4 me-4">
                        <h5 class="fw-bold mb-1 text-dark"><%= t.getTitulo() %></h5><p class="text-muted small mb-1"><%= t.getNombre_materia() %></p>
                    </div>
                    <div class="text-center border-end border-danger pe-4 me-4" style="width: 150px;">
                        <p class="mb-0 fw-bold text-dark"><i class="bi bi-calendar-x me-2 text-danger"></i><%= t.getFecha_entrega() %></p>
                        <p class="mb-0 small text-danger fw-bold">(<%= dias %> días de retraso)</p>
                    </div>
                    <div class="text-center border-end border-danger pe-4 me-4" style="width: 100px;"><span class="priority-badge prio-alta">Atrasada</span></div>
                    <div class="text-center" style="width: 120px;"><a href="alumno_entregar_tarea.jsp?id_tarea=<%= t.getId_tarea() %>" class="btn-ver w-100 d-block text-white" style="background-color: #dc3545;">Entregar</a></div>
                </div>
                <% } %>

                <% for (Tarea t : tareasEntregadas) { %>
                <div class="task-list-item d-flex align-items-center" data-estado="entregadas" data-materia="<%= t.getNombre_materia() %>" style="display: none; background-color: #f8fafc; opacity: 0.8;">
                    <div class="task-icon-large shadow-sm" style="background-color: #10b981;"><i class="bi bi-check2-all"></i></div>
                    <div class="flex-grow-1 border-end pe-4 me-4">
                        <h5 class="fw-bold mb-1 text-dark"><strike><%= t.getTitulo() %></strike></h5><p class="text-muted small mb-1"><%= t.getNombre_materia() %></p>
                    </div>
                    <div class="text-center border-end pe-4 me-4" style="width: 150px;">
                        <p class="mb-0 fw-bold text-success"><i class="bi bi-check-circle-fill me-2"></i>Completada</p>
                    </div>
                    <div class="text-center" style="width: 120px;"><button class="btn w-100 d-block btn-light border text-success fw-bold" disabled>Calificada</button></div>
                </div>
                <% } %>
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
    <script>
        let pestañaActual = 'pendientes';

        function cambiarPestana(estado, elemento) {
            pestañaActual = estado;
            document.querySelectorAll('#tabsTareas .nav-link').forEach(btn => {
                btn.classList.remove('active');
                btn.classList.add('text-muted');
                btn.style.backgroundColor = 'transparent';
                btn.style.color = '';
            });
            elemento.classList.add('active');
            elemento.classList.remove('text-muted');
            elemento.style.backgroundColor = 'var(--blue-falyd)';
            elemento.style.color = 'white';
            
            aplicarFiltros();
        }

        function aplicarFiltros() {
            const materiaFiltro = document.getElementById("filtroMateria").value;
            const tareas = document.querySelectorAll(".task-list-item");
            
            tareas.forEach(tarea => {
                const estadoTarea = tarea.getAttribute("data-estado");
                const materiaTarea = tarea.getAttribute("data-materia");
                
                const cumpleEstado = (pestañaActual === 'todas' || estadoTarea === pestañaActual);
                const cumpleMateria = (materiaFiltro === 'todas' || materiaTarea === materiaFiltro);
                
                if (cumpleEstado && cumpleMateria) {
                    tarea.style.display = "flex";
                    tarea.classList.remove("d-none");
                } else {
                    tarea.style.display = "none";
                    tarea.classList.add("d-none");
                }
            });
        }
        
    </script>
</body>
</html>