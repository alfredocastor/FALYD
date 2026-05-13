<%@page import="com.falyd.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");
    
    // Seguridad: Solo SECRETARIA puede entrar aquí
    if (user == null || !user.getTipo_usuario().equals("SECRETARIA")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Control Escolar - FALYD</title>
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
        <nav class="nav flex-column mt-2">
            <a class="nav-link active" href="#"><i class="bi bi-house-door me-2"></i> Inicio</a>
            <a class="nav-link" href="#"><i class="bi bi-person-plus me-2"></i> Inscribir Alumno</a>
            <a class="nav-link" href="#"><i class="bi bi-card-list me-2"></i> Directorio de Alumnos</a>
            <a class="nav-link" href="#"><i class="bi bi-journal-bookmark me-2"></i> Asignar Materias</a>
            <hr>
            <a class="nav-link text-danger" href="LogoutServlet"><i class="bi bi-box-arrow-left me-2"></i> Cerrar sesión</a>
        </nav>
    </div>

    <div class="header-panel d-flex justify-content-between align-items-center">
        <h5 class="mb-0 fw-bold" style="color: var(--blue-falyd);">Departamento de Control Escolar</h5>
        <div class="d-flex align-items-center">
            <div class="text-end me-3">
                <p class="mb-0 fw-bold small"><%= user.getNombre() %></p>
                <p class="mb-0 text-muted small">Secretaría</p>
            </div>
            <img src="https://ui-avatars.com/api/?name=<%= user.getNombre() %>&background=0b3b60&color=fff" class="rounded-circle" width="40">
        </div>
    </div>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="fw-bold">Panel de Secretaría</h2>
            <button class="btn btn-falyd"><i class="bi bi-plus-lg me-2"></i>Nuevo Alumno</button>
        </div>

        <div class="card card-custom p-4">
            <h5 class="fw-bold mb-4">Últimas Inscripciones Registradas</h5>
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>Matrícula</th>
                            <th>Nombre del Alumno</th>
                            <th>Grado Asignado</th>
                            <th>Fecha de Registro</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><strong>2026001</strong></td>
                            <td>Mariana López</td>
                            <td>1º A</td>
                            <td>Hoy</td>
                            <td>
                                <button class="btn btn-sm btn-outline-primary">Editar</button>
                            </td>
                        </tr>
                        <tr>
                            <td><strong>2026002</strong></td>
                            <td>Pedro Jiménez</td>
                            <td>3º B</td>
                            <td>Ayer</td>
                            <td>
                                <button class="btn btn-sm btn-outline-primary">Editar</button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>