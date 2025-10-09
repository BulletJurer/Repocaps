const express = require('express');
const path = require('path');
const app = express();
const port = 3000;

// Importa la conexión
const db = require('./db');

// Permite recibir JSON en peticiones POST
app.use(express.json());

// Middleware para servir archivos estáticos
app.use(express.static(path.join(__dirname, 'public')));

// Ruta principal - redirige al login
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'inicio-sesion.html'));
});

// ENDPOINT PARA AUTENTICACIÓN DE USUARIOS (Actualizado)
app.post('/api/login', (req, res) => {
  const { usuario, contrasena } = req.body;

  console.log('🔐 Intento de login:', { usuario });

  // Validar que se enviaron los datos requeridos
  if (!usuario || !contrasena) {
    return res.status(400).json({
      success: false,
      message: 'Usuario y contraseña son requeridos'
    });
  }

  // Consulta a la base de datos con la nueva estructura
  const query = `
    SELECT 
      rut, 
      nombre, 
      cargo, 
      region, 
      horario, 
      disponibilidad,
      contrasena,
      usuario
    FROM empleados 
    WHERE usuario = ? AND contrasena = ?
  `;
  
  db.query(query, [usuario, contrasena], (err, results) => {
    if (err) {
      console.error('❌ Error en consulta MySQL:', err);
      return res.status(500).json({
        success: false,
        message: 'Error del servidor'
      });
    }

    // Verificar si se encontró el empleado
    if (results.length > 0) {
      const empleado = results[0];
      console.log('✅ Login exitoso para:', empleado.nombre);
      
      // Enviar respuesta con todos los datos del empleado (excepto contraseña)
      res.json({
        success: true,
        message: 'Login exitoso',
        empleado: {
          rut: empleado.rut,
          nombre: empleado.nombre,
          cargo: empleado.cargo,
          region: empleado.region,
          horario: empleado.horario,
          disponibilidad: empleado.disponibilidad,
          usuario: empleado.usuario
          // NOTA: No enviamos la contraseña por seguridad
        }
      });
    } else {
      console.log('❌ Credenciales incorrectas para:', usuario);
      res.status(401).json({
        success: false,
        message: 'Usuario o contraseña incorrectos'
      });
    }
  });
});

// ENDPOINT PARA OBTENER LISTA DE EMPLEADOS (Actualizado)
app.get('/api/empleados', (req, res) => {
  const query = `
    SELECT 
      rut, 
      nombre, 
      cargo, 
      region, 
      horario, 
      disponibilidad,
      usuario
    FROM empleados
  `;
  
  db.query(query, (err, results) => {
    if (err) {
      console.error('❌ Error al obtener empleados:', err);
      return res.status(500).json({ error: 'Error del servidor' });
    }
    
    res.json(results);
  });
});

// ENDPOINT PARA ACTUALIZAR DISPONIBILIDAD
app.put('/api/empleados/:rut/disponibilidad', (req, res) => {
  const { rut } = req.params;
  const { disponibilidad } = req.body;

  const query = 'UPDATE empleados SET disponibilidad = ? WHERE rut = ?';
  
  db.query(query, [disponibilidad, rut], (err, results) => {
    if (err) {
      console.error('❌ Error al actualizar disponibilidad:', err);
      return res.status(500).json({ error: 'Error del servidor' });
    }
    
    if (results.affectedRows === 0) {
      return res.status(404).json({ error: 'Empleado no encontrado' });
    }
    
    res.json({ success: true, message: 'Disponibilidad actualizada' });
  });
});

// ENDPOINT PARA VERIFICAR ESTADO DEL SERVIDOR
app.get('/api/status', (req, res) => {
  res.json({ 
    status: 'Servidor funcionando correctamente',
    timestamp: new Date().toISOString(),
    base_datos: 'prueba_pepsi',
    tabla_empleados: 'disponible'
  });
});

// ENDPOINT PARA OBTENER ESTADÍSTICAS DEL SISTEMA
app.get('/api/estadisticas', (req, res) => {
  const estadisticas = {
    total_empleados: 0,
    empleados_disponibles: 0,
    empleados_ocupados: 0,
    empleados_ausentes: 0
  };

  const query = 'SELECT disponibilidad, COUNT(*) as count FROM empleados GROUP BY disponibilidad';
  
  db.query(query, (err, results) => {
    if (err) {
      console.error('❌ Error al obtener estadísticas:', err);
      return res.status(500).json({ error: 'Error del servidor' });
    }

    results.forEach(row => {
      estadisticas.total_empleados += row.count;
      switch(row.disponibilidad) {
        case 'disponible':
          estadisticas.empleados_disponibles = row.count;
          break;
        case 'ocupado':
          estadisticas.empleados_ocupados = row.count;
          break;
        case 'ausente':
          estadisticas.empleados_ausentes = row.count;
          break;
      }
    });

    res.json(estadisticas);
  });
});

// Ejemplo de ruta que lee datos desde MySQL (mantener compatibilidad)
app.get('/usuarios', (req, res) => {
  db.query('SELECT * FROM vehiculos', (err, results) => {
    if (err) {
      console.error('Error al consultar MySQL:', err);
      res.status(500).send('Error en la consulta');
      return;
    }
    res.json(results);
  });
});

// Manejo de rutas no encontradas
app.use((req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada' });
});

// Inicia el servidor
app.listen(port, () => {
  console.log(`🚀 Servidor iniciado en http://localhost:${port}`);
  console.log(`📊 Endpoints disponibles:`);
  console.log(`   POST /api/login - Autenticación de usuarios`);
  console.log(`   GET /api/empleados - Lista de empleados`);
  console.log(`   PUT /api/empleados/:rut/disponibilidad - Actualizar disponibilidad`);
  console.log(`   GET /api/estadisticas - Estadísticas del sistema`);
  console.log(`   GET /api/status - Estado del servidor`);
});