<%@page import="com.falyd.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Usuario user = (Usuario) sesion.getAttribute("usuarioActual");
    if (user == null || !user.getTipo_usuario().equals("ALUMNO")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Entregar Tarea - Panel del Alumno</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        :root { --blue-falyd: #0b3b60; --bg-light: #f4f7fe; --text-main: #2b3674; --border-color: #e2e8f0; }
        body { background-color: var(--bg-light); font-family: 'Segoe UI', sans-serif; color: var(--text-main); }
        .main-content { padding: 40px; max-width: 900px; margin: auto; }
        .card-custom { background: white; border-radius: 20px; padding: 35px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); border: 1px solid #f1f5f9; }
        
        .upload-zone { border: 2px dashed #cbd5e1; border-radius: 15px; padding: 40px 20px; text-align: center; background-color: #f8fafc; cursor: pointer; transition: 0.3s; }
        .upload-zone:hover { border-color: var(--blue-falyd); background-color: #e3f2fd; }
        .upload-icon { font-size: 3rem; color: #94a3b8; margin-bottom: 15px; }
        .upload-zone:hover .upload-icon { color: var(--blue-falyd); }
    </style>
</head>
<body>

    <div class="main-content">
        <a href="alumno_tareas.jsp" class="text-decoration-none text-muted mb-4 d-inline-block fw-bold"><i class="bi bi-arrow-left me-2"></i> Volver a mis tareas</a>
        
        <div class="card-custom">
            <div class="d-flex align-items-center mb-4 pb-3 border-bottom">
                <div class="me-3" style="width: 50px; height: 50px; background-color: #e3f2fd; color: var(--blue-falyd); border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem;"><i class="bi bi-journal-text"></i></div>
                <div>
                    <h4 class="fw-bold mb-1 text-dark">Resolver ejercicios de álgebra</h4>
                    <p class="mb-0 text-muted small"><i class="bi bi-calendar-event me-1"></i> Fecha límite: Hoy a las 23:59 • Matemáticas</p>
                </div>
            </div>

            <div class="mb-4">
                <h6 class="fw-bold text-dark mb-2">Instrucciones del profesor:</h6>
                <p class="text-muted small p-3 bg-light rounded-3 border">Por favor resuelve los ejercicios del tema 2.1 al 2.4 del libro de texto. Sube tu documento escaneado en formato PDF. Asegúrate de que los procedimientos sean legibles.</p>
            </div>

            <form action="EntregarTareaServlet" method="POST" enctype="multipart/form-data">
                
                <input type="hidden" name="id_tarea" value="<%= request.getParameter("id_tarea") %>">

                <div class="upload-zone mb-4" onclick="document.getElementById('archivoTarea').click()">
                    <i class="bi bi-cloud-arrow-up-fill upload-icon" id="iconoArchivo"></i>
                    <h6 class="fw-bold text-dark mb-1" id="textoArchivo">Haz clic para subir tu archivo</h6>
                    <p class="text-muted small mb-0">Formatos permitidos: PDF, DOCX, ZIP, JPG (Máx. 20MB)</p>
                    <input type="file" id="archivoTarea" name="archivoTarea" class="d-none" accept=".pdf,.doc,.docx,.zip,.jpg,.png" required 
                           onchange="document.getElementById('textoArchivo').innerText = this.files[0].name; document.getElementById('iconoArchivo').className = 'bi bi-file-earmark-check-fill upload-icon text-success';">
                </div>

                <div class="mb-4">
                    <label class="fw-bold small text-dark mb-2">Comentario para el profesor (opcional)</label>
                    <textarea class="form-control bg-light border-0" name="comentario" rows="3" placeholder="Escribe un mensaje si tuviste alguna duda con la tarea..."></textarea>
                </div>

                <div class="text-end border-top pt-4">
                    <a href="alumno_tareas.jsp" class="btn btn-light fw-bold text-muted border me-2 px-4">Cancelar</a>
                    <button type="submit" class="btn btn-primary fw-bold px-4" style="background-color: var(--blue-falyd); border-radius: 8px;"><i class="bi bi-send me-2"></i> Enviar tarea</button>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>