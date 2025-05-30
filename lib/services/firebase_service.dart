import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:othello/models/game_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Sign in anonymously
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      print('Error signing in anonymously: $e');
      return null;
    }
  }
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Create a new game room
  Future<String?> createGameRoom() async {
    try {
      // Ensure user is signed in
      if (_auth.currentUser == null) {
        await signInAnonymously();
      }
      
      // Generate a random 6-digit room code
      final roomCode = _generateRoomCode();
      
      // Create a new game
      final game = GameModel.newGame(
        gameMode: GameMode.online,
        creatorId: _auth.currentUser!.uid,
        roomCode: roomCode,
      );
      
      // Save to Firestore
      await _firestore.collection('games').doc(roomCode).set(game.toMap());
      
      return roomCode;
    } catch (e) {
      print('Error creating game room: $e');
      return null;
    }
  }
  
  // Join an existing game room
  Future<GameModel?> joinGameRoom(String roomCode) async {
    try {
      // Ensure user is signed in
      if (_auth.currentUser == null) {
        await signInAnonymously();
      }
      
      // Check if the room exists
      final gameDoc = await _firestore.collection('games').doc(roomCode).get();
      
      if (!gameDoc.exists) {
        return null;
      }
      
      // Get the game data
      final gameData = gameDoc.data() as Map<String, dynamic>;
      final game = GameModel.fromMap(gameData);
      
      // Check if the game already has two players
      if (game.joinerId != null && game.joinerId != _auth.currentUser!.uid) {
        return null; // Room is full
      }
      
      // Update the game with the joiner's ID
      if (game.joinerId == null) {
        await _firestore.collection('games').doc(roomCode).update({
          'joinerId': _auth.currentUser!.uid,
        });
      }
      
      return game;
    } catch (e) {
      print('Error joining game room: $e');
      return null;
    }
  }
  
  // Make a move in an online game
  Future<bool> makeMove(String roomCode, Position position) async {
    try {
      // Get the current game state
      final gameDoc = await _firestore.collection('games').doc(roomCode).get();
      
      if (!gameDoc.exists) {
        return false;
      }
      
      final gameData = gameDoc.data() as Map<String, dynamic>;
      final game = GameModel.fromMap(gameData);
      
      // Check if it's the player's turn
      final isBlackTurn = game.currentPlayer == CellState.black;
      final isCreator = _auth.currentUser!.uid == game.creatorId;
      
            // In online mode, creator plays as black, joiner as white
      if ((isBlackTurn && !isCreator) || (!isBlackTurn && isCreator)) {
        return false; // Not this player's turn
      }
      
      // Check if the move is valid
      if (!game.isValidMove(position)) {
        return false;
      }
      
      // Make the move
      final updatedGame = game.makeMove(position);
      
      // Update the game in Firestore
      await _firestore.collection('games').doc(roomCode).update(updatedGame.toMap());
      
      return true;
    } catch (e) {
      print('Error making move: $e');
      return false;
    }
  }
  
  // Listen for game updates
  Stream<GameModel> listenToGame(String roomCode) {
    return _firestore
        .collection('games')
        .doc(roomCode)
        .snapshots()
        .map((snapshot) => GameModel.fromMap(snapshot.data()!));
  }
  
  // Leave a game room
  Future<void> leaveGameRoom(String roomCode) async {
    try {
      // Get the current game state
      final gameDoc = await _firestore.collection('games').doc(roomCode).get();
      
      if (!gameDoc.exists) {
        return;
      }
      
      final gameData = gameDoc.data() as Map<String, dynamic>;
      final game = GameModel.fromMap(gameData);
      
      // If the current user is the creator, delete the game
      if (_auth.currentUser!.uid == game.creatorId) {
        await _firestore.collection('games').doc(roomCode).delete();
      } 
      // If the current user is the joiner, remove them from the game
      else if (_auth.currentUser!.uid == game.joinerId) {
        await _firestore.collection('games').doc(roomCode).update({
          'joinerId': null,
        });
      }
    } catch (e) {
      print('Error leaving game room: $e');
    }
  }
  
  // Generate a random 6-digit room code
  String _generateRoomCode() {
    final random = Random();
    final codeBuffer = StringBuffer();
    
    for (int i = 0; i < 6; i++) {
      codeBuffer.write(random.nextInt(10));
    }
    
    return codeBuffer.toString();
  }
  
  // Check if a room exists
  Future<bool> roomExists(String roomCode) async {
    try {
      final gameDoc = await _firestore.collection('games').doc(roomCode).get();
      return gameDoc.exists;
    } catch (e) {
      print('Error checking if room exists: $e');
      return false;
    }
  }
  
  // Get all active games for the current user
  Future<List<GameModel>> getActiveGames() async {
    try {
      if (_auth.currentUser == null) {
        return [];
      }
      
      final userId = _auth.currentUser!.uid;
      
      // Get games where the user is either the creator or joiner
      final creatorGames = await _firestore
          .collection('games')
          .where('creatorId', isEqualTo: userId)
          .where('status', isEqualTo: GameStatus.playing.index)
          .get();
          
      final joinerGames = await _firestore
          .collection('games')
          .where('joinerId', isEqualTo: userId)
          .where('status', isEqualTo: GameStatus.playing.index)
          .get();
          
      final games = <GameModel>[];
      
      for (final doc in creatorGames.docs) {
        games.add(GameModel.fromMap(doc.data()));
      }
      
      for (final doc in joinerGames.docs) {
        games.add(GameModel.fromMap(doc.data()));
      }
      
      return games;
    } catch (e) {
      print('Error getting active games: $e');
      return [];
    }
  }
}