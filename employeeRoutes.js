

//To get JSON
// const express = require('express');
// const router = express.Router();
// const { getAllEmployees } = require('./employeeService');

// // Define the `/all` route for `/employees`
// router.get('/employees/all', async (req, res) => {
//     try {
//         const employees = await getAllEmployees();
//         res.json(employees);
//     } catch (err) {
//         console.error('Error fetching employees:', err);
//         res.status(500).send('Internal Server Error');
//     }
// });

// module.exports = router;


// const express = require('express');
// const router = express.Router();
// const { getAllEmployees } = require('./employeeService');

// router.get('/employees/all', async (req, res) => {
//     try {
//         const employees = await getAllEmployees(); // Retrieve employee data
//         res.render('Emp_all', { employees }); // Pass data to EJS template
//     } catch (err) {
//         console.error('Error fetching employees:', err);
//         res.status(500).send('Internal Server Error');
//     }
// });

// module.exports = router;


const express = require('express');
const router = express.Router();
const { getAllEmployees } = require('./employeeService');

router.get('/employees/all', async (req, res) => {
    try {
        const employees = await getAllEmployees(); // Retrieve employee data
        console.log('Employees:', employees); // Debugging: Log data to ensure it's correct
        res.render('Emp_all', { employees }); // Pass data to EJS template
    } catch (err) {
        console.error('Error fetching employees:', err);
        res.status(500).send('Internal Server Error');
    }
});

module.exports = router;

