import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookingPage extends StatefulWidget {
  final String movieId;
  final String movieTitle;
  final String movieTime;
  final String moviePrice;

  const BookingPage({
    Key? key,
    required this.movieId,
    required this.movieTitle,
    required this.movieTime,
    required this.moviePrice,
  }) : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final String baseUrl = 'http://10.0.2.2:3000';
  List<String> selectedSeats = [];
  List<String> totalPrice=[];
  List<dynamic> availableSeats = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSeatAvailability();
  }

  Future<void> _fetchSeatAvailability() async {
    try {
    final response = await http.get(
      Uri.parse('$baseUrl/movies/${widget.movieId}/seats'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        availableSeats = List<Map<String, dynamic>>.from(
          data.map((item) => {
            'number': item['seat_number'].toString(),
            'isBooked': item['is_booked'] == 1,
          })
        );
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load seat availability');
    }
  } catch (e) {
    setState(() {
      errorMessage = 'Error: ${e.toString()}';
      isLoading = false;
    });
    }
  }

  void _toggleSeatSelection(String seatNumber) {
    setState(() {
      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber);
      } else {
        selectedSeats.add(seatNumber);
      }
    });
  }

  Future<void> _confirmBooking() async {
    print('Attempting to book seats: $selectedSeats');
    if (selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one seat')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'movie_id': widget.movieId,
          'seat_numbers': selectedSeats,
          'total_price': totalPrice,
          'payment_method':'cash',
        }),
      );
      print('Booking response: ${response.statusCode} - ${response.body}');
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationPage(
              movieTitle: widget.movieTitle,
              seats: selectedSeats,
              totalPrice: (selectedSeats.length * double.parse(widget.moviePrice)).toStringAsFixed(2),
              bookingId: responseData['bookingId'].toString(),
            ),
          ),
        );
      } else if (response.statusCode == 409) {
        // Handle seat conflicts
        final bookedSeats = List<String>.from(responseData['bookedSeats']);
        setState(() {
          selectedSeats.removeWhere((seat) => bookedSeats.contains(seat));
          availableSeats = availableSeats.map((seat) {
            if (bookedSeats.contains(seat['number'].toString())) {
              return {...seat, 'isBooked': true};
            }
            return seat;
          }).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Seats ${bookedSeats.join(', ')} are no longer available')),
        );
      } else {
        throw Exception(responseData['message'] ?? 'Booking failed');
      }
    } catch (e) {
      print('Booking error: $e'); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.movieTitle}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Column(
                  children: [
                    // Movie Info Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.movieTitle,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('Time: ${widget.movieTime}'),
                          Text('Price: \$${widget.moviePrice} per seat'),
                          Divider(),
                          Text(
                            'Selected Seats: ${selectedSeats.isEmpty ? 'None' : selectedSeats.join(', ')}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Total: \$${(selectedSeats.length * double.parse(widget.moviePrice)).toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    
                    // Seat Selection Grid
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          childAspectRatio: 1,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: availableSeats.length,
                        itemBuilder: (context, index) {
                        final seat = availableSeats[index];
                        return SeatWidget(
                        seatNumber: seat['number'],
                        isBooked: seat['isBooked'],
                        isSelected: selectedSeats.contains(seat['number'].toString()),
                        onTap: () => _toggleSeatSelection(seat['number'].toString()),
    );
                        },
                      ),
                    ),
                    
                    // Book Button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _confirmBooking,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Colors.amber,
                        ),
                        child: Text(
                          'CONFIRM BOOKING',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class SeatWidget extends StatelessWidget {
  final String seatNumber;
  final bool isBooked;
  final bool isSelected;
  final VoidCallback onTap;
  final String? seatType; // Optional: 'standard', 'premium', 'vip'
  final double seatSize; // Allows customization

  const SeatWidget({
    Key? key,
    required this.seatNumber,
    required this.isBooked,
    required this.isSelected,
    required this.onTap,
    this.seatType,
    this.seatSize = 40.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _getSeatStatus(),
      child: GestureDetector(
        onTap: isBooked ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: seatSize,
          height: seatSize,
          decoration: BoxDecoration(
            color: _getSeatColor(),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _getBorderColor(),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              seatNumber,
              style: TextStyle(
                color: _getTextColor(),
                fontWeight: FontWeight.bold,
                fontSize: seatSize * 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getSeatColor() {
    if (isBooked) {
      return Colors.grey.shade400; // Booked seats
    } else if (isSelected) {
      return Colors.green.shade400; // Selected seats
    } else {
      // Available seats - different colors by type
      switch (seatType) {
        case 'premium':
          return Colors.amber.shade300;
        case 'vip':
          return Colors.purple.shade300;
        default: // standard
          return Colors.blue.shade400;
      }
    }
  }

  Color _getBorderColor() {
    return isSelected ? Colors.green.shade700 : Colors.grey.shade300;
  }

  Color _getTextColor() {
    return isBooked ? Colors.grey.shade100 : Colors.white;
  }

  String _getSeatStatus() {
    if (isBooked) return 'Booked';
    if (isSelected) return 'Selected (Tap to remove)';
    return '${seatType ?? 'Standard'} seat (Tap to select)';
  }
}

class BookingConfirmationPage extends StatelessWidget {
  final String movieTitle;
  final List<String> seats;
  final String totalPrice;
  final String bookingId;

  const BookingConfirmationPage({
    required this.movieTitle,
    required this.seats,
    required this.totalPrice,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Confirmed'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(Icons.check_circle, color: Colors.green, size: 80),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Booking Confirmed!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30),
            Text('Movie: $movieTitle', style: TextStyle(fontSize: 18)),
            Text('Booking ID: $bookingId', style: TextStyle(fontSize: 18)),
            Text('Seats: ${seats.join(', ')}', style: TextStyle(fontSize: 18)),
            Text('Total: \$$totalPrice', style: TextStyle(fontSize: 18)),
            SizedBox(height: 30),
            Text(
              'Please bring this confirmation to the theater box office to complete your purchase.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}