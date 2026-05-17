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
    <title>Crear Nueva Tarea - FALYD</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        :root { 
            --blue-falyd: #0b3b60; 
            --red-falyd: #d32f2f; 
            --bg-light: #f4f7fe;
            --text-main: #2b3674;
            --border-color: #e2e8f0;
        }
        body { background-color: var(--bg-light); font-family: 'Segoe UI', sans-serif; color: var(--text-main); }
        
        .sidebar { width: 260px; height: 100vh; position: fixed; background: white; border-right: none; box-shadow: 2px 0 20px rgba(0,0,0,0.04); z-index: 100; border-bottom-right-radius: 50px; }
        .nav-link { color: #8f9bba; padding: 12px 25px; font-weight: 600; margin: 4px 15px; border-radius: 10px; transition: all 0.3s; }
        .nav-link i { font-size: 1.2rem; margin-right: 12px; }
        .nav-link:hover { background-color: #f4f7fe; color: var(--blue-falyd); }
        .nav-link.active { background-color: #e3f2fd; color: var(--blue-falyd); }
        .nav-link.text-danger { color: var(--red-falyd) !important; }
        
        .main-content { margin-left: 260px; padding: 30px 40px; padding-bottom: 80px;}
        
        .form-container { background: white; border-radius: 20px; padding: 40px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); }
        .form-label { font-weight: 600; font-size: 0.9rem; color: var(--text-main); margin-bottom: 8px; }
        .form-control, .form-select { border-radius: 10px; border: 1px solid var(--border-color); padding: 10px 15px; font-size: 0.95rem; color: #4a5568; }
        .form-control:focus, .form-select:focus { border-color: #a0aec0; box-shadow: none; }
        
        .editor-toolbar { border: 1px solid var(--border-color); border-bottom: none; border-top-left-radius: 10px; border-top-right-radius: 10px; padding: 10px 15px; background-color: #f8fafc; }
        .editor-toolbar button { background: none; border: none; color: #64748b; margin-right: 15px; cursor: pointer; transition: 0.2s; }
        .editor-toolbar button:hover { color: var(--blue-falyd); }
        .editor-textarea { border-top-left-radius: 0; border-top-right-radius: 0; min-height: 200px; }
        
        .btn-cancel { background: white; border: 1px solid var(--border-color); color: var(--text-main); font-weight: 600; border-radius: 10px; padding: 10px 25px; text-decoration: none;}
        .btn-cancel:hover { background: #f8fafc; color: var(--text-main); }
        .btn-submit { background: var(--blue-falyd); border: none; color: white; font-weight: 600; border-radius: 10px; padding: 10px 25px; transition: 0.2s; }
        .btn-submit:hover { background: #082d4a; }
        
        .section-title { font-size: 1.1rem; font-weight: 700; color: var(--text-main); margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px solid #edf2f7; }
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
             <a class="nav-link" href="maestro_recursos.jsp"><i class="bi bi-book"></i> Recursos</a>
                
                
            <div class="mt-auto mb-4">
                
<a class="nav-link text-danger" href="#" data-bs-toggle="modal" data-bs-target="#modalCerrarSesion"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>            </div>
        </nav>
    </div>

    <div class="main-content">
        <div class="mb-4">
            <a href="maestro_tareas.jsp" class="text-decoration-none fw-bold" style="color: #64748b;">
                <i class="bi bi-arrow-left me-1"></i> Tareas <span class="mx-2">/</span> <span style="color: var(--blue-falyd);">Nueva tarea</span>
            </a>
        </div>

        <div class="form-container">
            <div class="d-flex align-items-center mb-5">
                <div class="icon-box me-3" style="font-size: 2.5rem; color: var(--blue-falyd);">
                    <i class="bi bi-journal-plus"></i>
                </div>
                <div>
                    <h2 class="fw-bold mb-1">Crear nueva tarea</h2>
                    <p class="text-muted mb-0">Completa la información básica para asignar la tarea a tus alumnos.</p>
                </div>
            </div>

            <form action="TareaServlet" method="POST">
                <input type="hidden" name="accion" value="crear">
                <input type="hidden" name="id_usuario_maestro" value="<%= user.getId_usuario() %>">

                <h5 class="section-title">Información general</h5>
                <div class="row g-4 mb-5">
                    <div class="col-md-6">
                        <label class="form-label">Título de la tarea <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="titulo" placeholder="Ej. Resolución de ecuaciones de primer grado" required>
                    </div>
                    
                    <div class="col-md-3">
                        <label class="form-label">Materia <span class="text-danger">*</span></label>
                        <select name="id_materia" class="form-select text-muted" required>
                            <option value="" selected disabled>Selecciona una materia</option>
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

                    <div class="col-md-3">
                        <label class="form-label">Fecha de entrega <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-calendar-event"></i></span>
                            <input type="date" class="form-control border-start-0 ps-0 text-muted" name="fecha_entrega" required>
                        </div>
                    </div>
                </div>

                <h5 class="section-title">Descripción de la Tarea</h5>
                <div class="mb-5">
                    <label class="form-label">Instrucciones para los alumnos <span class="text-danger">*</span></label>
                    <div class="editor-toolbar d-flex align-items-center">
                        <button type="button" class="fw-bold">Párrafo <i class="bi bi-chevron-down ms-1" style="font-size:0.7rem;"></i></button>
                        <div style="border-left: 1px solid #cbd5e1; height: 20px; margin-right: 15px;"></div>
                        <button type="button"><i class="bi bi-type-bold"></i></button>
                        <button type="button"><i class="bi bi-type-italic"></i></button>
                        <button type="button"><i class="bi bi-type-underline"></i></button>
                        <div style="border-left: 1px solid #cbd5e1; height: 20px; margin-right: 15px;"></div>
                        <button type="button"><i class="bi bi-list-ul"></i></button>
                        <button type="button"><i class="bi bi-list-ol"></i></button>
                    </div>
                    <textarea class="form-control editor-textarea" name="descripcion" placeholder="Escribe aquí las instrucciones, páginas del libro o detalles de la tarea..." required></textarea>
                </div>

                <div class="d-flex justify-content-end border-top pt-4 mt-2">
                    <a href="maestro_tareas.jsp" class="btn btn-cancel me-3">Cancelar</a>
                    <button type="submit" class="btn btn-submit"><i class="bi bi-save me-2"></i>Guardar y Asignar Tarea</button>
                </div>
            </form>

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