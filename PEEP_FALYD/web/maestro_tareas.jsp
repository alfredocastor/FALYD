<%@page import="com.falyd.modelo.Tarea"%>
<%@page import="com.falyd.dao.TareaDAO"%>
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
    <title>Tareas - Panel del Maestro</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        :root { 
            --blue-falyd: #0b3b60; 
            --red-falyd: #d32f2f; 
            --bg-light: #f4f7fe;
            --text-main: #2b3674;
        }
        body { background-color: var(--bg-light); font-family: 'Segoe UI', sans-serif; color: var(--text-main); }
        
        /* Sidebar */
        .sidebar { width: 260px; height: 100vh; position: fixed; background: white; border-right: none; box-shadow: 2px 0 20px rgba(0,0,0,0.04); z-index: 100; border-bottom-right-radius: 50px; }
        .nav-link { color: #8f9bba; padding: 12px 25px; font-weight: 600; margin: 4px 15px; border-radius: 10px; transition: all 0.3s; }
        .nav-link i { font-size: 1.2rem; margin-right: 12px; }
        .nav-link:hover { background-color: #f4f7fe; color: var(--blue-falyd); }
        .nav-link.active { background-color: #e3f2fd; color: var(--blue-falyd); }
        .nav-link.text-danger { color: var(--red-falyd) !important; }
        
        .main-content { margin-left: 260px; padding: 30px 40px; }
        
        /* Estilos de la página de Tareas */
        .task-card { background: white; border-radius: 20px; padding: 20px; border: 1px solid #edf2f7; transition: all 0.2s; margin-bottom: 15px; }
        .task-card:hover { box-shadow: 0 10px 20px rgba(0,0,0,0.03); transform: translateY(-2px); border-color: #e2e8f0; }
        
        .task-icon { width: 60px; height: 60px; border-radius: 15px; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; color: white; }
        
        .btn-custom-outline { border: 1px solid #e2e8f0; color: var(--text-main); border-radius: 10px; font-weight: 600; padding: 6px 15px; font-size: 0.85rem; background: white;}
        .btn-custom-outline:hover { background-color: #f8fafc; }
        .btn-action { font-size: 0.85rem; font-weight: 600; border-radius: 8px; padding: 6px 12px; border: 1px solid #e2e8f0; background: white; width: 100%; text-align: left; margin-bottom: 6px; transition: 0.2s; }
        .btn-action:hover { background-color: #f8fafc; }
        .btn-action i { margin-right: 8px; font-size: 1rem; }
        .btn-danger-action { color: var(--red-falyd); }
        .btn-danger-action:hover { background-color: #fff5f5; border-color: #fed7d7; }
        
        .status-badge { padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 700; }
        .status-active { background-color: #def7ec; color: #03543f; }
    </style>
</head>
<body>

    <div class="sidebar d-flex flex-column">
        <div class="p-4 text-center">
            <img src="img/Logo.png" alt="FALYD Logo" style="width: 120px; margin-bottom: 5px;">
        </div>
        <nav class="nav flex-column mt-2 flex-grow-1">
            <a class="nav-link" href="panel_maestro.jsp"><i class="bi bi-house-door-fill"></i> Inicio</a>
            <a class="nav-link active" href="maestro_tareas.jsp"><i class="bi bi-check2-square"></i> Tareas</a>
            <a class="nav-link" href="maestro_calendario.jsp"><i class="bi bi-calendar3"></i> Calendario</a>
            <a class="nav-link" href="maestro_alumnos.jsp"><i class="bi bi-people-fill"></i> Alumnos</a>
            <a class="nav-link" href="maestro_calificaciones.jsp"><i class="bi bi-clipboard-data"></i> Calificaciones</a>
            <a class="nav-link" href="#"><i class="bi bi-book"></i> Recursos</a>
            
                
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
                <button class="btn btn-link text-muted p-0 me-3 position-relative">
                    <i class="bi bi-bell-fill fs-5"></i>
                    <span class="position-absolute top-0 start-100 translate-middle p-1 bg-danger border border-light rounded-circle"></span>
                </button>
                <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=e3f2fd&color=0b3b60" class="rounded-circle me-2" width="40">
                <div class="me-3 lh-sm">
                    <p class="mb-0 fw-bold small"><%= user.getNombre() %></p>
                    <p class="mb-0 text-muted" style="font-size: 0.75rem;">Maestro</p>
                </div>
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-end mb-4">
            <div>
                <h1 class="fw-bold mb-1">Tareas</h1>
                <p class="text-muted mb-0">Gestiona, asigna y califica las tareas de tus clases.</p>
            </div>
            <a href="maestro_crear_tarea.jsp" class="btn btn-primary text-decoration-none" style="background-color: var(--blue-falyd); border-radius: 10px; font-weight: 600; padding: 10px 20px;">
                <i class="bi bi-plus-lg me-2"></i>Crear nueva tarea
            </a>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-5">
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted rounded-start-3"><i class="bi bi-search"></i></span>
                    <input type="text" class="form-control border-start-0 rounded-end-3 bg-white" placeholder="Buscar tarea...">
                </div>
            </div>
            <div class="col-md-3">
                <select class="form-select rounded-3 border-light shadow-sm text-muted fw-bold">
                    <option selected value="">Todas las materias</option>
                    <%
                        MateriaDAO matDAO = new MateriaDAO();
                        List<Materia> misMaterias = matDAO.listarMateriasPorMaestro(user.getId_usuario());
                        
                        for(Materia m : misMaterias) {
                    %>
                        <option value="<%= m.getId_materia() %>"><%= m.getNombre_materia() %></option>
                    <%
                        }
                    %>
                </select>
            </div>
            <div class="col-md-4">
                <select class="form-select rounded-3 border-light shadow-sm text-muted fw-bold">
                    <option selected>Todos los estados</option>
                    <option>Activa</option>
                </select>
            </div>
        </div>

        <%
            TareaDAO tDAO = new TareaDAO();
            List<Tarea> listaTareas = tDAO.listarTareasPorMaestro(user.getId_usuario());

            if (listaTareas.isEmpty()) {
        %>
            <div class="text-center py-5">
                <i class="bi bi-inbox text-muted" style="font-size: 4rem; opacity: 0.5;"></i>
                <h5 class="fw-bold mt-3 text-muted">Aún no has creado ninguna tarea</h5>
                <p class="text-muted small">Haz clic en "Crear nueva tarea" para empezar a asignar actividades.</p>
            </div>
        <%
            } else {
                for (Tarea t : listaTareas) {
        %>
            <div class="task-card d-flex align-items-center">
                <div class="task-icon me-4 shadow-sm" style="background: linear-gradient(135deg, #4299e1 0%, #3182ce 100%);">
                    <i class="bi bi-journal-text"></i>
                </div>
                <div class="flex-grow-1 pe-4 border-end">
                    <h5 class="fw-bold mb-1"><%= t.getTitulo() %></h5>
                    <p class="text-muted small mb-3 text-truncate" style="max-width: 400px;"><%= t.getDescripcion() %></p>
                    <span class="text-muted small fw-bold"><i class="bi bi-folder me-1"></i> <%= t.getNombre_materia() %></span>
                </div>
                <div class="px-4 border-end" style="width: 220px;">
                    <span class="status-badge status-active d-inline-block mb-3">Activa</span>
                    <p class="mb-1 small"><i class="bi bi-calendar3 text-muted me-2"></i><span class="text-muted">Fecha de entrega</span><br><strong class="ms-4"><%= t.getFecha_entrega() %></strong></p>
                </div>
                <div class="ps-4" style="width: 150px;">
                    <button class="btn-action"><i class="bi bi-eye text-primary"></i> Ver</button>
                    <button class="btn-action"><i class="bi bi-check2-square text-success"></i> Calificar</button>
                    <button class="btn-action"><i class="bi bi-pencil text-secondary"></i> Editar</button>
                    <button class="btn-action btn-danger-action"><i class="bi bi-trash"></i> Eliminar</button>
                </div>
            </div>
        <%
                }
            }
        %>
        </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>