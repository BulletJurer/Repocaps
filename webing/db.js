const mysql = require('mysql2');

// Crear conexión con tu servidor local de MySQL
const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',          // user de MySQL
  password: 'mnu14567',// tu contraseña
  database: 'prueba_pepsi', 
  port: 3306     
});

// Verificar conexión
connection.connect((err) => {
  if (err) {
    console.error('❌ Error al conectar con la base de datos:', err);
    return;
  }
  console.log('✅ Conectado a MySQL correctamente');
});

module.exports = connection;
