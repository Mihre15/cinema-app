const express = require("express");
const mysql = require("mysql2/promise"); // Changed to promise interface
const bodyParser = require("body-parser");
const cors = require("cors");
const multer = require("multer");
const fs = require("fs");
const session = require('express-session');

const app = express();

// Configure CORS to allow all origins
app.use(cors({
  origin: 'http://10.0.2.2:3000',
  credentials: true
}));

// Session configuration
app.use(session({
  secret: 'your-secret-key',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false } // set to true if using https
}));

app.use(express.json());
app.use(bodyParser.json());

// Serve static files from the 'uploads' folder
app.use("/uploads", express.static("uploads"));

// Configure multer for image upload
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + "-" + file.originalname);
  },
});
const upload = multer({ storage: storage });

// Create connection pool instead of single connection
const pool = mysql.createPool({
  host: "localhost",
  user: "root",
  password: "",
  database: "cinema_app",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Test the database connection
pool.getConnection()
  .then(connection => {
    console.log("Connected to MySQL DB");
    connection.release();
  })
  .catch(err => {
    console.error("Database connection failed:", err);
    process.exit(1);
  });

// Helper function to execute queries
async function query(sql, params) {
  const [rows] = await pool.execute(sql, params || []);
  return rows;
}

// Middleware to check if user is logged in
// Update your requireLogin middleware
const requireLogin = async (req, res, next) => {
  console.log('Session ID:', req.sessionID); // 🚨 Debug
  console.log('Session data:', req.session); // 🚨 Debug
  console.log('Cookies:', req.headers.cookie); // 🚨 Debug

  if (!req.session.userId) {
    console.log('No user ID in session'); // Debug
    return res.status(401).json({ message: "Please login first" });
  }
  
  // Verify user exists
  try {
    const [users] = await pool.query(
      'SELECT id FROM users WHERE id = ?', 
      [req.session.userId]
    );
    
    if (users.length === 0) {
      console.log('User not found in database'); // Debug
      return res.status(401).json({ message: "Invalid user session" });
    }
    
    next();
  } catch (err) {
    console.error('Session verification error:', err);
    res.status(500).json({ message: "Session verification failed" });
  }
};

// Register User
app.post("/signup", async (req, res) => {
  try {
    const { name, email, password } = req.body;
    const sql = "INSERT INTO users (name, email, password) VALUES (?, ?, ?)";
    
    try {
      const [result] = await pool.query(sql, [name, email, password]);
      // Create session for the new user
      req.session.userId = result.insertId;
      res.status(200).json({ 
        message: "User registered!",
        user: { id: result.insertId, name, email }
      });
    } catch (err) {
      if (err.code === "ER_DUP_ENTRY") {
        return res.status(409).json({ message: "Email already exists" });
      }
      throw err;
    }
  } catch (err) {
    console.error("Signup error:", err);
    res.status(500).json({ error: err.message });
  }
});

// Login
app.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const sql = "SELECT id, name, email FROM users WHERE email = ? AND password = ?";
    const results = await query(sql, [email, password]);
    
    if (results.length > 0) {
      // Create session
      req.session.userId = results[0].id;
      res.json({ 
        message: "Login successful", 
        
        user: {
          id: results[0].id,
          name: results[0].name,
          email: results[0].email
        }
      });
    } else {
      res.status(401).json({ message: "Invalid password or email" });
    }
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ error: err.message });
  }
});
// Admin Login
app.post("/admin/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const [results] = await pool.query(
      "SELECT * FROM admin WHERE email = ? AND password = ?",
      [email, password]
    );

    if (results.length > 0) {
      res.json({ message: "Admin login successful", admin: results[0] });
    } else {
      res.status(401).json({ message: "Invalid admin credentials" });
    }
  } catch (err) {
    console.error("Admin login error:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
});


// Get current user details
// app.get("/current-user", (req, res) => {
//   if (!req.session.userId) {
//     return res.status(401).json({ message: "Not logged in" });
//   }

//   // Get user details from database
//   pool.query("SELECT id, name, email FROM users WHERE id = ?", [req.session.userId])
//     .then(([results]) => {
//       if (results.length > 0) {
//         res.json({
//           isLoggedIn: true,
//           user: {
//             id: results[0].id,
//             name: results[0].name,
//             email: results[0].email
//           }
//         });
//       } else {
//         res.status(404).json({ message: "User not found" });
//       }
//     })
//     .catch(err => {
//       console.error("Error fetching user details:", err);
//       res.status(500).json({ error: err.message });
//     });
// });

// Logout
// app.post("/logout", (req, res) => {
//   req.session.destroy((err) => {
//     if (err) {
//       return res.status(500).json({ message: "Error logging out" });
//     }
//     res.json({ message: "Logged out successfully" });
//   });
// });

// Get current user
app.get("/user", (req, res) => {
  if (!req.session.userId) {
    return res.status(401).json({ message: "Not logged in" });
  }
  res.json({ userId: req.session.userId });
});

// Movie upload endpoint - updated to create seats
app.post("/movies", upload.single("image"), async (req, res) => {
  try {
    const { title, genre, time, price } = req.body;
    const imagePath = req.file ? req.file.filename : "default.jpg";
    
    const connection = await pool.getConnection();
    try {
      await connection.beginTransaction();
      
      // 1. Insert movie
      const [movieResult] = await connection.query(
        "INSERT INTO movies (title, genre, time, price, image) VALUES (?, ?, ?, ?, ?)",
        [title, genre, time, price, imagePath]
      );
      
      const movieId = movieResult.insertId;
      
      // 2. Create seats (50 seats per movie as example)
      const seats = [];
      const rows = ['A', 'B', 'C', 'D', 'E'];
      const seatsPerRow = 10;
      
      for (let row of rows) {
        for (let i = 1; i <= seatsPerRow; i++) {
          seats.push([movieId, `${row}${i}`, 0]); // 0 means not booked
        }
      }
      
      await connection.query(
        "INSERT INTO seats (movie_id, seat_number, is_booked) VALUES ?",
        [seats]
      );
      
      await connection.commit();
      
      res.status(200).json({ 
        message: "Movie and seats added successfully",
        movieId: movieId
      });
    } catch (err) {
      await connection.rollback();
      throw err;
    } finally {
      connection.release();
    }
  } catch (err) {
    console.error("Movie upload error:", err);
    res.status(500).json({ 
      message: err.message,
      error: err
    });
  }
});
// Get all movies
app.get("/movies", async (req, res) => {
  try {
    const [movies] = await pool.query("SELECT * FROM movies ORDER BY id DESC");
    res.status(200).json(movies);
  } catch (err) {
    console.error("Error fetching movies:", err);
    res.status(500).json({ message: "Failed to fetch movies", error: err.message });
  }
});


// Delete movie by ID
app.delete("/movies/:id", async (req, res) => {
  const id = req.params.id;
  try {
    await pool.query("DELETE FROM seats WHERE movie_id = ?", [id]);
    
    const [result] = await pool.query("DELETE FROM movies WHERE id = ?", [id]);
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Movie not found" });
    }
    res.status(200).json({ message: "Movie deleted successfully" });
  } catch (err) {
    console.error("Failed to delete movie:", err);
    res.status(500).json({ message: "Failed to delete movie", error: err.message });
  }
});
// booking 
// booking endpoint - fixed
// Booking seats
// Booking seats (Login is optional now)
app.post('/bookings', async (req, res) => {
  console.log('🔥 /bookings endpoint reached!'); 
  console.log('✅ Reached /bookings route');
  console.log('Session ID:', req.sessionID);
  console.log('Cookies:', req.headers.cookie);
  console.log('Session data:', req.session);

  const { movie_id, seat_numbers } = req.body;
  const user_id = req.session.userId || null;

  if (!seat_numbers || seat_numbers.length === 0) {
    return res.status(400).json({ message: 'Please select at least one seat' });
  }

  const seats = Array.isArray(seat_numbers) ? seat_numbers : seat_numbers.split(',');

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    // 1. Check seat availability
    const [bookedSeats] = await connection.query(
      'SELECT seat_number FROM seats WHERE movie_id = ? AND seat_number IN (?) AND is_booked = 1',
      [movie_id, seats]
    );

    if (bookedSeats.length > 0) {
      const bookedNumbers = bookedSeats.map(s => s.seat_number);
      return res.status(409).json({
        message: 'Some seats are already booked',
        bookedSeats: bookedNumbers
      });
    }

    // 2. Get movie price
    const [movie] = await connection.query(
      'SELECT price FROM movies WHERE id = ?',
      [movie_id]
    );

    if (movie.length === 0) {
      return res.status(404).json({ message: 'Movie not found' });
    }

    const pricePerSeat = movie[0].price;
    const totalPrice = seats.length * pricePerSeat;

    // 3. Insert booking
    const [bookingResult] = await connection.query(
      'INSERT INTO bookings (user_id, movie_id, seat_numbers, total_price) VALUES (?, ?, ?, ?)',
      [user_id, movie_id, seats.join(','), totalPrice]
    );

    // 4. Update booked seats
    await connection.query(
      'UPDATE seats SET is_booked = 1 WHERE movie_id = ? AND seat_number IN (?)',
      [movie_id, seats]
    );

    await connection.commit();

    res.status(201).json({
      message: 'Booking successful!',
      bookingId: bookingResult.insertId,
      seats: seats,
      totalPrice: totalPrice
    });
  } catch (err) {
    await connection.rollback();
    console.error('Booking error:', err);
    res.status(500).json({ message: 'Booking failed', error: err.message });
  } finally {
    connection.release();
  }
});


// Get seat availability for a movie
app.get("/movies/:id/seats", async (req, res) => {
  try {
    const movieId = req.params.id;

    const [seats] = await pool.query(
      `SELECT
        s.seat_number,
        s.is_booked,
        CASE WHEN s.is_booked = 1 THEN b.user_id ELSE NULL END as booked_by_user_id,
        CASE WHEN s.is_booked = 1 THEN u.name ELSE NULL END as booked_by_user_name
      FROM seats s
      LEFT JOIN bookings b ON s.movie_id = b.movie_id AND FIND_IN_SET(s.seat_number, b.seat_numbers)
      LEFT JOIN users u ON b.user_id = u.id
      WHERE s.movie_id = ?
      ORDER BY s.seat_number`,
      [movieId]
    );

    res.status(200).json(seats);
  } catch (err) {
    console.error("Error fetching seat availability:", err);
    res.status(500).json({ message: "Failed to fetch seat availability", error: err.message });
  }
});

// Get user bookings — NO requireLogin
app.get('/user/bookings', async (req, res) => {
  if (!req.session.userId) {
    return res.status(401).json({ message: 'User not logged in' });
  }

  try {
    const [bookings] = await pool.query(
      `SELECT b.id, m.title, m.image, b.seat_numbers, b.booking_date
       FROM bookings b
       JOIN movies m ON b.movie_id = m.id
       WHERE b.user_id = ?`,
      [req.session.userId]
    );
    res.json(bookings);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching bookings', error: err.message });
  }
});
// Get last booking for the current user
app.get("/user/last-booking", async (req, res) => {
  if (!req.session.userId) {
    return res.status(401).json({ message: "User not logged in" });
  }

  try {
    const [result] = await pool.query(
      `SELECT b.id AS booking_id, b.seat_numbers, b.total_price, b.booking_date,
              m.id AS movie_id, m.title, m.genre, m.time, m.price, m.image
       FROM bookings b
       JOIN movies m ON b.movie_id = m.id
       WHERE b.user_id = ?
       ORDER BY b.booking_date DESC
       LIMIT 1`,
      [req.session.userId]
    );

    if (result.length === 0) {
      return res.status(404).json({ message: "No booking found" });
    }

    const booking = result[0];
    res.status(200).json({
      bookingId: booking.booking_id,
      seats: booking.seat_numbers.split(","),
      totalPrice: booking.total_price,
      bookingDate: booking.booking_date,
      movie: {
        id: booking.movie_id,
        title: booking.title,
        genre: booking.genre,
        time: booking.time,
        price: booking.price,
        image: booking.image
      }
    });
  } catch (err) {
    console.error("Error fetching last booking:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
});



// Ensure uploads folder exists
const uploadDir = "./uploads";
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

// Start server on all network interfaces
const PORT = 3000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on port ${PORT}`);
});
