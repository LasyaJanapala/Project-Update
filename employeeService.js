const mysql = require('mysql2/promise'); // Use the promise-based API


const pool = mysql.createPool({
    connectionLimit: 10, // Adjust based on your needs
    host: 'localhost',
    user: 'root',
    password: 'HACK#15@LOCK',
    database: 'Standalone'
});


async function getAllEmployees() {
    try {
        const [results] = await pool.query('SELECT Image, Name, PersonNumber FROM Employee');
        return results; // This should be an array of employee objects
    } catch (err) {
        console.error('Error fetching employees:', err);
        throw err;
    }
}

module.exports = { getAllEmployees };