<%@page import="com.falyd.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.falyd.modelo.Alumno"%>
<%@page import="com.falyd.dao.AlumnoDAO"%>
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
           <a class="nav-link active" href="panel_secretaria.jsp"><i class="bi bi-card-list me-2"></i> Directorio de Alumnos</a>
            <a class="nav-link" href="secretaria_materias.jsp"><i class="bi bi-journal-bookmark me-2"></i> Asignar Materias</a>
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
            <button class="btn btn-falyd" data-bs-toggle="modal" data-bs-target="#modalNuevoAlumno">
                <i class="bi bi-plus-lg me-2"></i>Nuevo Alumno
            </button>
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
                        <%
                            // Llamamos al DAO para traer la lista de la base de datos
                            AlumnoDAO aluDAO = new AlumnoDAO();
                            List<Alumno> listaAlumnos = aluDAO.listarAlumnos();
                            
                            // Recorremos la lista y dibujamos una fila <tr> por cada alumno
                           for (Alumno alu : listaAlumnos) {
                        %>
                        <tr>
                            <td><strong><%= alu.getId_alumno() %></strong></td>
                            <td><%= alu.getNombre() %> <br><small class="text-muted"><%= alu.getCorreo() %></small></td>
                            <td>
                                <span class="badge <%= (alu.getGrupo() != null && !alu.getGrupo().isEmpty()) ? "bg-info text-dark" : "bg-secondary" %>">
                                    <%= (alu.getGrupo() != null && !alu.getGrupo().isEmpty()) ? alu.getGrupo() : "Sin asignar" %>
                                </span>
                            </td>
                            <td>
                                <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %>
                            </td>
                            <td>
                                <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#modalEditar<%= alu.getId_alumno() %>">
                                    <i class="bi bi-pencil"></i> Editar
                                </button>
                                
                                <button class="btn btn-sm btn-outline-danger ms-1" data-bs-toggle="modal" data-bs-target="#modalEliminar<%= alu.getId_alumno() %>">
                                    <i class="bi bi-trash"></i> Eliminar
                                </button>

                                <div class="modal fade" id="modalEliminar<%= alu.getId_alumno() %>" tabindex="-1" aria-hidden="true">
                                    <div class="modal-dialog modal-dialog-centered">
                                        <div class="modal-content border-0 shadow">
                                            <div class="modal-header bg-danger text-white">
                                                <h5 class="modal-title fw-bold"><i class="bi bi-exclamation-triangle-fill me-2"></i>Confirmar Baja</h5>
                                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                            </div>
                                            <form action="AlumnoServlet" method="POST">
                                                <div class="modal-body p-4 text-center">
                                                    <input type="hidden" name="accion" value="eliminar">
                                                    <input type="hidden" name="id_usuario" value="<%= alu.getId_usuario() %>">
                                                    <input type="hidden" name="id_alumno" value="<%= alu.getId_alumno() %>">
                                                    
                                                    <i class="bi bi-x-circle text-danger mb-3" style="font-size: 3rem;"></i>
                                                    <p class="fs-5 mb-1">¿Estás seguro de que deseas dar de baja a <br><strong><%= alu.getNombre() %></strong>?</p>
                                                    <p class="text-muted small">Esta acción no se puede deshacer.</p>
                                                </div>
                                                <div class="modal-footer bg-light justify-content-center">
                                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                                    <button type="submit" class="btn btn-danger">Sí, dar de baja</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>

                                <div class="modal fade" id="modalEditar<%= alu.getId_alumno() %>" tabindex="-1" aria-hidden="true">
                                    <div class="modal-dialog modal-dialog-centered">
                                        <div class="modal-content border-0 shadow">
                                            <div class="modal-header bg-primary text-white">
                                                <h5 class="modal-title fw-bold"><i class="bi bi-pencil-square me-2"></i>Editar Alumno</h5>
                                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                            </div>
                                            <form action="AlumnoServlet" method="POST">
                                                <div class="modal-body p-4">
                                                    <input type="hidden" name="accion" value="editar">
                                                    <input type="hidden" name="id_usuario" value="<%= alu.getId_usuario() %>">
                                                    <input type="hidden" name="id_alumno" value="<%= alu.getId_alumno() %>">
                                                    
                                                    <div class="mb-3">
                                                        <label class="form-label fw-bold small text-muted">Nombre Completo</label>
                                                        <input type="text" class="form-control" name="nombre" value="<%= alu.getNombre() %>" required>
                                                    </div>
                                                    
                                                    <div class="mb-3">
                                                        <label class="form-label fw-bold small text-muted">Correo Electrónico</label>
                                                        <input type="email" class="form-control" name="correo" value="<%= alu.getCorreo() %>" required>
                                                    </div>
                                                    
                                                    <div class="mb-3">
                                                        <label class="form-label fw-bold small text-muted">Nueva Contraseña (Opcional)</label>
                                                        <input type="password" class="form-control" name="password" placeholder="Dejar en blanco para conservar actual">
                                                    </div>
                                                    
                                                    <div class="mb-3">
                                                        <label class="form-label fw-bold small text-muted">Asignar Grupo</label>
                                                        <select class="form-select" name="id_grupo" required>
                                                            <option value="1" <%= alu.getId_grupo() == 1 ? "selected" : "" %>>1º A</option>
                                                            <option value="2" <%= alu.getId_grupo() == 2 ? "selected" : "" %>>2º B</option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="modal-footer bg-light">
                                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                                    <button type="submit" class="btn btn-primary">Actualizar Cambios</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                                </td>
                        </tr>
                        <%
                            } // Fin del ciclo for
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="modal fade" id="modalNuevoAlumno" tabindex="-1" aria-labelledby="modalNuevoAlumnoLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header" style="background-color: var(--blue-falyd); color: white;">
                    <h5 class="modal-title fw-bold" id="modalNuevoAlumnoLabel">
                        <i class="bi bi-person-plus-fill me-2"></i>Inscribir Nuevo Alumno
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                
                <form action="AlumnoServlet" method="POST">
                    <div class="modal-body p-4">
                        
                        <input type="hidden" name="accion" value="agregar">
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold small text-muted">Nombre Completo</label>
                            <input type="text" class="form-control" name="nombre" placeholder="Ej. Juan Pérez" required>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold small text-muted">Correo Electrónico (Usuario)</label>
                            <input type="email" class="form-control" name="correo" placeholder="alumno@peep.com" required>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold small text-muted">Contraseña Temporal</label>
                            <input type="password" class="form-control" name="password" placeholder="Mínimo 6 caracteres" required>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold small text-muted">Asignar Grupo</label>
                            <select class="form-select" name="id_grupo" required>
                                <option value="" selected disabled>Selecciona un grupo...</option>
                                <option value="1">1º A</option>
                                <option value="2">2º B</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                        <button type="submit" class="btn btn-falyd">Guardar Alumno</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>