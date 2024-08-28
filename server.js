const express = require('express');
const bodyParser = require('body-parser');
const multer = require('multer');
const path = require('path');
const mysql = require('mysql2/promise'); // Use the promise-based API
const bcrypt = require('bcrypt');
const cookieParser = require('cookie-parser');
const session = require('express-session');
const { format } = require('date-fns'); // Ensure date-fns is installed
const { formatWithOptions } = require('util');

const app = express();

//employee change
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
const { getAllEmployees } = require('./employeeService');
const router = express.Router();

// Import routes
const employeeRoutes = require('./employeeRoutes');

// Middleware
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public'))); // For serving static files if needed

// Use routes
app.use('/', employeeRoutes);




// Middleware
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static('public'));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use(cookieParser());
app.use(session({
  secret: 'your_secret_key', // Replace with a strong secret key
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false } // Set to true if using HTTPS
}));

// Set EJS as the view engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views')); // Directory for your EJS templates

// Create MySQL connection pool
const pool = mysql.createPool({
  connectionLimit: 10, // Adjust based on your needs
  host: 'localhost',
  user: 'root',
  password: 'HACK#15@LOCK',
  database: 'Standalone'
});

// Test MySQL connection
pool.getConnection()
  .then(connection => {
    console.log('Connected to the database');
    connection.release(); // Release the connection back to the pool
  })
  .catch(err => {
    console.error('Error connecting to the database:', err);
    process.exit(1); // Exit process if unable to connect
  });

app.get('/', (req, res) => {
  const message = req.session.message || ''; // Get the message from session or set to empty string
  req.session.message = null; // Clear the message from the session
  res.render('login', { title: 'Login', message: message });
});

// Handle login
app.post('/login', async (req, res) => {
  const { personNumber, password } = req.body;

  try {
    const [results] = await pool.query('SELECT * FROM User WHERE PersonNumber = ?', [personNumber]);

    if (results.length === 0) {
      req.session.message = 'Invalid Person Number';
      return res.redirect('/'); // Redirect to login with message
    }

    const user = results[0];

    if (password === '1234') {
      const hashedPassword = await bcrypt.hash(password, 10);
      await pool.query('UPDATE User SET Password = ? WHERE PersonNumber = ?', [hashedPassword, personNumber]);

      req.session.user = user; // Store the entire user object
      return res.redirect('/dashboard');
    }

    const result = await bcrypt.compare(password, user.Password);
    if (result) {
      req.session.user = user; // Store the entire user object
      res.redirect('/dashboard');
    } else {
      req.session.message = 'Invalid Password';
      res.redirect('/'); // Redirect to login with message
    }
  } catch (err) {
    console.error('Error handling login:', err);
    res.status(500).send('Error handling login');
  }
});

// Serve dashboard or other secured page
app.get('/dashboard', (req, res) => {
  if (!req.session.user) {
    return res.redirect('/'); // Redirect to login if not authenticated
  }

  res.render('dashboard', { title: 'Dashboard' }); // Render 'views/dashboard.ejs' with a title variable
});

// Success Page
app.get('/success', (req, res) => {
  res.render('success');
});

// Handle logout
app.get('/logout', (req, res) => {
  req.session.destroy(err => {
    if (err) {
      console.error('Error destroying session:', err);
      res.status(500).send('Error logging out');
      return;
    }
    res.redirect('/'); // Redirect to login page after logout
  });
});

// Manage Team Page
app.get('/manage-team', async (req, res) => {
  if (!req.session.user) {
    return res.redirect('/'); // Redirect to login if not authenticated
  }

  try {
    const connection = await pool.getConnection();
    
    const [teams] = await connection.query(`
      SELECT 
        t.SupervisorPersonNumber,
        e.Name AS SupervisorName,
        h.FrameNumber,
        e1.Name AS TradesMen1Name,
        e2.Name AS TradesMen2Name,
        e3.Name AS TradesMen3Name,
        s.Name AS ServiceName,
        ts.CompletedAt IS NOT NULL AS ServiceStatus
      FROM Team t
      LEFT JOIN Employee e ON t.SupervisorPersonNumber = e.PersonNumber
      LEFT JOIN Helicopter h ON t.HelicopterFrameNumber = h.FrameNumber
      LEFT JOIN Employee e1 ON t.TradesMen1PersonNumber = e1.PersonNumber
      LEFT JOIN Employee e2 ON t.TradesMen2PersonNumber = e2.PersonNumber
      LEFT JOIN Employee e3 ON t.TradesMen3PersonNumber = e3.PersonNumber
      LEFT JOIN TeamService ts ON t.SupervisorPersonNumber = ts.SupervisorPersonNumber
      LEFT JOIN Services s ON ts.ServiceID = s.ServiceID
      WHERE t.CreatedAt IS NOT NULL
    `);
    console.log(teams)
    connection.release();
    
    // Check if there are any active teams
    const hasActiveTeams = teams.length > 0;

    res.render('manage-team', {
      title: 'Manage Team',
      teams: teams,
      hasActiveTeams: hasActiveTeams
    });
  } catch (err) {
    console.error('Error fetching team data:', err);
    res.status(500).send('Error fetching team data');
  }
});

// Route to Serve Assign Team Form
app.get('/assign-team', async (req, res) => {
  if (!req.session.user) {
      return res.redirect('/'); // Redirect to login if not authenticated
  }

  try {
      // Fetch available helicopters, supervisors, and tradesmen from the database
      const [helicoptersResult] = await pool.query('SELECT FrameNumber FROM Helicopter WHERE TeamID IS NULL AND Active_Status = 1');
      const [supervisorsResult] = await pool.query('SELECT PersonNumber, Name FROM Employee WHERE Designation = "Supervisor" AND TeamID IS NULL AND Active_Status = 1');
      const [tradesmenResult] = await pool.query('SELECT PersonNumber, Name FROM Employee WHERE Designation = "Tradesmen" AND TeamID IS NULL AND Active_Status = 1');

      console.log('Helicopters:', helicoptersResult);
      console.log('Supervisors:', supervisorsResult);
      console.log('Tradesmen:', tradesmenResult);

      // Pass the data to the EJS template
      res.render('assign-team', {
          title: 'Assign Team',
          helicopters: helicoptersResult,
          supervisors: supervisorsResult,
          tradesmen: tradesmenResult
      });
  } catch (err) {
    console.log('Helicopters:', helicoptersResult);
      console.log('Supervisors:', supervisorsResult);
      console.log('Tradesmen:', tradesmenResult);
      console.error('Error fetching data:', err);
      res.status(500).send('Error fetching data');
  }
});


// Route to Handle Assign Team Form Submission
app.post('/assign-team', async (req, res) => {
  if (!req.session.user) {
    return res.redirect('/'); // Redirect to login if not authenticated
  }

  const { helicopter, supervisor, tradesmen } = req.body;

  // Check if all required fields are provided
  if (!helicopter || !supervisor || !tradesmen || tradesmen.length < 3) {
    req.session.message = 'Please select all required fields and at least three tradesmen.';
    return res.redirect('/assign-team');
  }

  let connection;

  try {
    // Start a transaction
    connection = await pool.getConnection();
    await connection.beginTransaction();

    // Insert the new team into the Team table
    // Here the TeamID is actually the SupervisorPersonNumber
    const [result] = await connection.query(
      'INSERT INTO Team (SupervisorPersonNumber, HelicopterFrameNumber, TradesMen1PersonNumber, TradesMen2PersonNumber, TradesMen3PersonNumber) VALUES (?, ?, ?, ?, ?)',
      [supervisor, helicopter, tradesmen[0], tradesmen[1], tradesmen[2]]
    );

    // Set the TeamID to the Supervisor's PersonNumber
    const teamId = supervisor;

    // Update Employee table with the new TeamID for supervisor and tradesmen
    await connection.query(
      'UPDATE Employee SET TeamID = ? WHERE PersonNumber IN (?,?, ?, ?)',
      [teamId, supervisor, tradesmen[0], tradesmen[1], tradesmen[2]]
    );

    // Update Helicopter table with the new TeamID
    await connection.query(
      'UPDATE Helicopter SET TeamID = ? WHERE FrameNumber = ?',
      [teamId, helicopter]
    );

    // Commit the transaction
    await connection.commit();
    connection.release();

    req.session.message = 'Team assigned successfully!';
    res.redirect('/success');
  } catch (err) {
    console.error('Error assigning team:', err);

    if (connection) {
      try {
        // Rollback the transaction if an error occurs
        await connection.rollback();
      } catch (rollbackErr) {
        console.error('Error rolling back transaction:', rollbackErr);
      } finally {
        connection.release();
      }
    }

    req.session.message = 'Error assigning team. Please try again.';
    res.redirect('/assign-team');
  }
});

// Route to render the Assign Service page
app.get('/assign-service/:teamID', async (req, res) => {
  const teamID = req.params.teamID;

  if (!req.session.user) {
      return res.redirect('/'); // Redirect to login if not authenticated
  }

  try {
      // Fetch the team data
      const [teamResults] = await pool.query('SELECT * FROM Team WHERE SupervisorPersonNumber = ?', [teamID]);

      if (teamResults.length === 0) {
          return res.status(404).send('Team not found');
      }

      const team = teamResults[0];

      // Fetch the available services
      const [services] = await pool.query('SELECT * FROM Services WHERE Active_Status = 1');
      console.log(team);
      res.render('assign-service', { team, services });
  } catch (err) {
      console.error('Error fetching team or services data:', err);
      res.status(500).send('Error fetching data');
  }
});

// Handle the form submission for assigning services to a team
app.post('/assign-service/:teamID', async (req, res) => {
  const teamID = req.params.teamID;
  const selectedServices = req.body.services; // Get selected services from form

  if (!req.session.user) {
      return res.redirect('/'); // Redirect to login if not authenticated
  }

  if (!selectedServices || selectedServices.length === 0) {
      req.session.message = 'Please select at least one service.';
      return res.redirect(`/assign-service/${teamID}`);
  }

  let connection;

  try {
      connection = await pool.getConnection();
      await connection.beginTransaction();

      // Insert selected services for the team along with the current timestamp
      for (let serviceID of selectedServices) {
          await connection.query(
              'INSERT INTO TeamService (SupervisorPersonNumber, ServiceID, AssignedAt) VALUES (?, ?, CURRENT_TIMESTAMP)',
              [teamID, serviceID]
          );
      }

      await connection.commit();
      connection.release();

      req.session.message = 'Services assigned successfully!';
      res.redirect('/success');
  } catch (err) {
      console.error('Error assigning services:', err);

      if (connection) {
          try {
              await connection.rollback();
          } catch (rollbackErr) {
              console.error('Error rolling back transaction:', rollbackErr);
          } finally {
              connection.release();
          }
      }

      req.session.message = 'Error assigning services. Please try again.';
      res.redirect(`/assign-service/${teamID}`);
  }
});


// Route to render the Lend Tools page
app.get('/lend-tools', async (req, res) => {
  const { frameNumber, supervisor } = req.query;

  // Check if the user is authenticated
  if (!req.session.user) {
    return res.redirect('/'); // Redirect to login if not authenticated
  }

  try {


    // Define the maximum allowed tools per team
    const maxToolsPerTeam = 20;

    // Fetch the total number of tools issued to the team with the given supervisor
    const [issuedToolsResult] = await pool.query(`
      SELECT COUNT(*) AS IssuedCount
      FROM Tokens 
      WHERE TeamID = ? AND Status = 'Issued'
    `, [supervisor]);

    const issuedCount = issuedToolsResult[0].IssuedCount;
    const remainingLimit = maxToolsPerTeam - issuedCount;

    // Fetch available tools with updated remaining limit
    const [tools] = await pool.query(`
      SELECT 
        t.ToolID, 
        tk.ToolkitName, 
        tk.Color1,
        tk.Color2,
        t.Name, 
        t.Size, 
        t.PartNo, 
        t.NetQuantity AS QtyAvailable
      FROM Tools t
      JOIN ToolKits tk ON t.ToolkitID = tk.ToolkitID
      WHERE t.Active_Status = 1 AND t.NetQuantity>0
    `);

    // Fetch employees in the team
    const [employees] = await pool.query(`
      SELECT PersonNumber, Name
      FROM Employee
      WHERE TeamID = ?
    `, [supervisor]);

    // Fetch pending services
    const [services] = await pool.query(`
      SELECT ts.ServiceID, s.Name
      FROM TeamService ts
      JOIN Services s ON ts.ServiceID = s.ServiceID
      WHERE ts.SupervisorPersonNumber = ? AND ts.CompletedAt IS NULL
    `, [supervisor]);

    // Render the 'lend-tools' page with the fetched data
    res.render('lend-tools', {
      title: 'Lend Tools',
      tools,
      employees,
      frameNumber,
      supervisor,
      services,
      remainingLimit,  // Pass the remaining limit to the EJS file
      maxToolsPerTeam   // Optionally pass the maximum tools per team
    });

  } catch (err) {
    console.error('Error fetching tools or employees:', err);
    res.status(500).send('Error fetching tools or employees');
  }
});


// Handle the form submission for lending tools
app.post('/lend-tools', async (req, res) => {
  const { frameNumber, supervisor, EmployeeID, selectedTools, service } = req.body;
  console.log(req.body);  // Log the request body to debug
  const issuedBy = req.session.user.PersonNumber;

  if (!req.session.user) {
    return res.redirect('/');  // Redirect to login if not authenticated
  }

  // Ensure selectedTools is an array
  if (!Array.isArray(selectedTools) || selectedTools.length === 0) {
    req.session.message = 'No tools selected. Please select tools to lend.';
    return res.redirect(`/lend-tools?frameNumber=${frameNumber}&supervisor=${supervisor}`);
  }

  let connection;

  try {
    connection = await pool.getConnection();
    await connection.beginTransaction();

    for (const toolID of selectedTools) {
      // Check available quantity
      const [[tool]] = await connection.query(`
        SELECT TotalQuantity - IFNULL((SELECT SUM(1) FROM Tokens WHERE ToolID = ? AND Status = 'Issued'), 0) AS AvailableQty
        FROM Tools
        WHERE ToolID = ?
      `, [toolID, toolID]);

      if (tool.AvailableQty <= 0) {
        throw new Error('Insufficient quantity for tool ID: ' + toolID);
      }

      // Insert token record
      await connection.query(`
        INSERT INTO Tokens (ToolID, TeamID, EmployeeID, ServiceID, Status, IssuedBy)
        VALUES (?, ?, ?, ?, 'Issued', ?)
      `, [toolID, supervisor, EmployeeID, service, issuedBy]);

      // Decrement Net Quantity
      await connection.query(`
        UPDATE Tools
        SET NetQuantity = NetQuantity - 1
        WHERE ToolID = ?
      `, [toolID]);
    }

    await connection.commit();
    connection.release();

    req.session.message = 'Tools lent successfully!';
    res.redirect('/success');
  } catch (err) {
    console.error('Error lending tools:', err);

    if (connection) {
      try {
        await connection.rollback();
      } catch (rollbackErr) {
        console.error('Error rolling back transaction:', rollbackErr);
      } finally {
        connection.release();
      }
    }

    req.session.message = 'Error lending tools. Please try again.';
    res.redirect(`/lend-tools?frameNumber=${frameNumber}&supervisor=${supervisor}`);
  }
});


app.get('/inservice', (req, res) => {
  // Dummy data - Replace this with actual data from your database
  const employees = [
    { photo: 'path_to_photo1.jpg', name: 'John Doe', personNumber: '12345', assignedTo: 'CH1234' },
    { photo: 'path_to_photo2.jpg', name: 'Jane Smith', personNumber: '67890', assignedTo: 'CH1235' },
    // Add more employee objects as needed
  ];

  res.render('Emp_Inservice', { employees });
});


router.get('/employees', async (req, res) => {
  try {
    const employees = await getAllEmployees();
    res.json(employees);
  } catch (err) {
    console.error('Error fetching employees:', err);
    res.status(500).send('Internal Server Error');
  }
});

// async function getAllEmployees() {
//   try {
//     const [results] = await pool.query('SELECT * FROM Employee');
//     return results;
//   } catch (err) {
//     console.error('Error executing query:', err);
//     throw err;
//   }
// }

module.exports = { getAllEmployees };


//app.use('/api', router);


 
// Start server
app.listen(3000, () => {
  console.log('Server running on port 3000');
});
