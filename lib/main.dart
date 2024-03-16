import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => CityEntryScreen(),
        '/weatherDetails': (context) => WeatherDetailsScreen(),
        '/forecast': (context) => ForecastScreen(),
      },
    );
  }
}

class CityEntryScreen extends StatelessWidget {
  final TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter City Name')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City Name'),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/weatherDetails',
                    arguments: _cityController.text,
                  );
                },
                child: Text('Get Weather'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class WeatherDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? cityName = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(title: Text('Weather Details')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Weather Details for ${cityName ?? "Unknown"}',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forecast', arguments: cityName);
              },
              child: Text('View 5-Day Forecast'),
            ),
          ],
        ),
      ),
    );
  }
}

class ForecastScreen extends StatelessWidget {
  Future<List<dynamic>> _fetchForecastData(String? city) async {
    if (city == '') {
      throw Exception('City name is null');
    }

    final apiKey = 'YOUR_API_KEY'; // Replace with your API key
    final apiUrl = '';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['list'];
    } else {
      throw Exception('Failed to fetch forecast data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? cityName = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(title: Text('5-Day Forecast for ${cityName ?? "Unknown"}')),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchForecastData(cityName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<dynamic> forecastData = snapshot.data!;
            return ListView.builder(
              itemCount: forecastData.length,
              itemBuilder: (context, index) {
                final forecast = forecastData[index];
                final dateTime = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
                final temperature = (forecast['main']['temp'] - 273.15).toStringAsFixed(2);
                final condition = forecast['weather'][0]['main'];
                return ListTile(
                  title: Text('Date: ${dateTime.toString()}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Temperature: $temperature°C'),
                      Text('Condition: $condition'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
