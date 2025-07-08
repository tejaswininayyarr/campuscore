// lib/screens/add_event_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '/models/event.dart';

class AddEventScreen extends StatefulWidget {
  final Event? event; // Optional: for editing existing events

  const AddEventScreen({super.key, this.event});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController(); // Re-added
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      // If editing an existing event, pre-fill fields
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _imageUrlController.text = widget.event!.imageUrl; // Re-added
      _locationController.text = widget.event!.location;
      _organizerController.text = widget.event!.organizer;
      _contactInfoController.text = widget.event!.contactInfo;
      _selectedDate = widget.event!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.event!.date);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose(); // Re-added
    _locationController.dispose();
    _organizerController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final DateTime eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final newEvent = Event(
        id: widget.event?.id ?? '', // ID is empty for new events, Firestore will assign
        title: _titleController.text,
        description: _descriptionController.text,
        imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : 'https://via.placeholder.com/150', // Use text field value
        date: eventDateTime,
        time: DateFormat('h:mm a').format(eventDateTime), // Format for display
        location: _locationController.text,
        organizer: _organizerController.text,
        contactInfo: _contactInfoController.text,
      );

      try {
        if (widget.event == null) {
          // Add new event
          await FirebaseFirestore.instance.collection('events').add(newEvent.toFirestore());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event added successfully!')),
          );
        } else {
          // Update existing event
          await FirebaseFirestore.instance.collection('events').doc(widget.event!.id).update(newEvent.toFirestore());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event updated successfully!')),
          );
        }
        Navigator.of(context).pop(); // Go back to previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save event: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Add New Event' : 'Edit Event', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Event Title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Image URL Text Field
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL (e.g., from Google Photos, Imgur)',
                        hintText: 'https://example.com/image.jpg',
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    // End Image URL Text Field
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Event Date',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Event Time',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(_selectedTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _organizerController,
                      decoration: const InputDecoration(labelText: 'Organizer'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactInfoController,
                      decoration: const InputDecoration(labelText: 'Contact Info'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(widget.event == null ? 'Add Event' : 'Update Event'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}