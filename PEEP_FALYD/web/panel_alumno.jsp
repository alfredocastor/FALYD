<%@page import="com.falyd.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Verificamos que haya una sesión activa
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");
    
    // Si alguien intenta entrar a la URL sin loguearse, lo regresamos al login
    if (user == null || !user.getTipo_usuario().equals("ALUMNO")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel del Alumno - FALYD</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        :root { --blue-falyd: #0b3b60; --red-falyd: #d32f2f; }
        body { background-color: #f0f2f5; font-family: 'Segoe UI', sans-serif; }
        
        /* Estilo del Sidebar */
        .sidebar { width: 250px; height: 100vh; position: fixed; background: white; border-right: 1px solid #ddd; }
        .nav-link { color: #555; padding: 12px 20px; font-weight: 500; }
        .nav-link:hover, .nav-link.active { background-color: #e9ecef; color: var(--blue-falyd); border-left: 4px solid var(--blue-falyd); }
        
        /* Contenido Principal */
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
            <a class="nav-link" href="#"><i class="bi bi-journal-text me-2"></i> Mis clases</a>
            <a class="nav-link" href="#"><i class="bi bi-check2-square me-2"></i> Tareas</a>
            <a class="nav-link" href="#"><i class="bi bi-calendar3 me-2"></i> Calendario</a>
            <a class="nav-link" href="#"><i class="bi bi-folder2 me-2"></i> Recursos</a>
            <a class="nav-link" href="#"><i class="bi bi-bar-chart me-2"></i> Calificaciones</a>
            <hr>
            <a class="nav-link text-danger" href="LogoutServlet"><i class="bi bi-box-arrow-left me-2"></i> Cerrar sesión</a>
        </nav>
    </div>

    <div class="header-panel d-flex justify-content-between align-items-center">
        <h5 class="mb-0 fw-bold" style="color: var(--blue-falyd);">Sistema Web Escolar Luis Moya</h5>
        <div class="d-flex align-items-center">
            <i class="bi bi-bell me-4 fs-5"></i>
            <div class="text-end me-3">
                <p class="mb-0 fw-bold small"><%= user.getNombre() %></p>
                <p class="mb-0 text-muted small">Alumno</p>
            </div>
            <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=0b3b60&color=fff" class="rounded-circle" width="40">
        </div>
    </div>

    <div class="main-content">
        <div class="row">
            <div class="col-12 mb-4">
                <h2 class="fw-bold">¡Bienvenido(a), <%= user.getNombre().split(" ")[0] %>! 👋</h2>
                <p class="text-muted">Plataforma Escolar para Escuela Primaria (PEEP)</p>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-md-8">
                <div class="card card-custom p-4 mb-4">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h5 class="fw-bold mb-0">Tareas Pendientes</h5>
                        <a href="#" class="btn btn-sm btn-outline-primary">Ver todas</a>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Materia</th>
                                    <th>Actividad</th>
                                    <th>Entrega</th>
                                    <th>Estatus</th>
                                    <th>Acción</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td><span class="badge bg-primary-subtle text-primary">Matemáticas</span></td>
                                    <td>Fracciones complejas</td>
                                    <td>Hoy, 23:59</td>
                                    <td><span class="badge bg-warning text-dark">Pendiente</span></td>
                                    <td><button class="btn btn-sm btn-falyd">Subir</button></td>
                                </tr>
                                <tr>
                                    <td><span class="badge bg-success-subtle text-success">Español</span></td>
                                    <td>Resumen de lectura</td>
                                    <td>Mañana</td>
                                    <td><span class="badge bg-warning text-dark">Pendiente</span></td>
                                    <td><button class="btn btn-sm btn-falyd">Subir</button></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card card-custom p-4 mb-4" style="background-color: #0b3b60; color: white;">
                    <h5 class="fw-bold mb-3">Promedio Actual</h5>
                    <h1 class="display-4 fw-bold">9.5</h1>
                    <p class="mb-0 opacity-75">¡Vas por muy buen camino!</p>
                </div>

                <div class="card card-custom p-4">
                    <h5 class="fw-bold mb-3"><i class="bi bi-megaphone me-2"></i> Avisos</h5>
                    <div class="border-bottom pb-2 mb-2">
                        <p class="mb-1 fw-bold small">Junta de padres</p>
                        <p class="mb-0 text-muted extra-small">Viernes 15 de Mayo - 08:00 AM</p>
                    </div>
                    <div class="border-bottom pb-2 mb-2">
                        <p class="mb-1 fw-bold small">Entrega de boletas</p>
                        <p class="mb-0 text-muted extra-small">Lunes 18 de Mayo</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>