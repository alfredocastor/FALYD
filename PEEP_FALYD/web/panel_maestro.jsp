<%@page import="com.falyd.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Seguridad: Verificamos sesión y rol de Maestro
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
    <title>Panel del Maestro - FALYD</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        :root { --blue-falyd: #0b3b60; --red-falyd: #d32f2f; }
        body { background-color: #f0f2f5; font-family: 'Segoe UI', sans-serif; }
        
        .sidebar { width: 250px; height: 100vh; position: fixed; background: white; border-right: 1px solid #ddd; }
        .nav-link { color: #555; padding: 12px 20px; font-weight: 500; }
        .nav-link:hover, .nav-link.active { background-color: #e9ecef; color: var(--blue-falyd); border-left: 4px solid var(--blue-falyd); }
        
        .main-content { margin-left: 250px; padding: 30px; }
        .header-panel { background: white; padding: 15px 30px; border-bottom: 1px solid #ddd; margin-left: 250px; }
        .card-custom { border-radius: 15px; border: none; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
    </style>
</head>
<body>

    <div class="sidebar d-flex flex-column">
        <div class="p-4">
            <img src="img/Logo.png" alt="Logo" style="width: 120px;">
        </div>
        <nav class="nav flex-column">
            <a class="nav-link active" href="#"><i class="bi bi-house-door me-2"></i> Inicio</a>
            <a class="nav-link" href="#"><i class="bi bi-people me-2"></i> Mis Grupos</a>
            <a class="nav-link" href="#"><i class="bi bi-file-earmark-plus me-2"></i> Asignar Tareas</a>
            <a class="nav-link" href="#"><i class="bi bi-check-all me-2"></i> Calificar</a>
            <a class="nav-link" href="#"><i class="bi bi-graph-up me-2"></i> Reportes</a>
            <hr>
            <a class="nav-link text-danger" href="LogoutServlet"><i class="bi bi-box-arrow-left me-2"></i> Cerrar sesión</a>
        </nav>
    </div>

    <div class="header-panel d-flex justify-content-between align-items-center">
        <h5 class="mb-0 fw-bold" style="color: var(--blue-falyd);">Sistema Web Escolar Luis Moya</h5>
        <div class="d-flex align-items-center">
            <i class="bi bi-bell me-4 fs-5"></i>
            <div class="text-end me-3">
                <p class="mb-0 fw-bold small">Prof. <%= user.getNombre() %></p>
                <p class="mb-0 text-muted small">Docente</p>
            </div>
            <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=0b3b60&color=fff" class="rounded-circle" width="40">
        </div>
    </div>

    <div class="main-content">
        <div class="row">
            <div class="col-12 mb-4 d-flex justify-content-between align-items-center">
                <div>
                    <h2 class="fw-bold">Bienvenido, Prof. <%= user.getNombre().split(" ")[0] %></h2>
                    <p class="text-muted">Resumen de actividades docentes.</p>
                </div>
                <button class="btn btn-falyd" style="background-color: var(--blue-falyd); color: white;">
                    <i class="bi bi-plus-circle me-2"></i>Nueva Tarea
                </button>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-md-4">
                <div class="card card-custom p-4 text-center">
                    <h1 class="display-5 fw-bold" style="color: var(--blue-falyd);">3</h1>
                    <p class="text-muted mb-0">Grupos Asignados</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card card-custom p-4 text-center">
                    <h1 class="display-5 fw-bold text-warning">45</h1>
                    <p class="text-muted mb-0">Tareas por Calificar</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card card-custom p-4 text-center">
                    <h1 class="display-5 fw-bold text-success">92%</h1>
                    <p class="text-muted mb-0">Promedio General</p>
                </div>
            </div>

            <div class="col-12 mt-5">
                <div class="card card-custom p-4">
                    <h5 class="fw-bold mb-4">Mis Grupos Actuales</h5>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Grupo</th>
                                    <th>Materia</th>
                                    <th>Alumnos</th>
                                    <th>Próxima Clase</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td><span class="badge bg-secondary">5º A</span></td>
                                    <td>Matemáticas</td>
                                    <td>32</td>
                                    <td>Hoy, 08:00</td>
                                    <td>
                                        <button class="btn btn-sm btn-outline-primary"><i class="bi bi-eye"></i> Ver</button>
                                        <button class="btn btn-sm btn-outline-success"><i class="bi bi-journal-check"></i> Asistencia</button>
                                    </td>
                                </tr>
                                <tr>
                                    <td><span class="badge bg-secondary">6º B</span></td>
                                    <td>Historia</td>
                                    <td>28</td>
                                    <td>Mañana, 10:00</td>
                                    <td>
                                        <button class="btn btn-sm btn-outline-primary"><i class="bi bi-eye"></i> Ver</button>
                                        <button class="btn btn-sm btn-outline-success"><i class="bi bi-journal-check"></i> Asistencia</button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>