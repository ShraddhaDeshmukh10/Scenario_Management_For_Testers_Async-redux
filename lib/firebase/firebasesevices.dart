import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scenario_management_tool_for_testers/model/scenario_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Scenario>> fetchScenariosFromFirebase() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('scenarios').get();
      return snapshot.docs
          .map((doc) => Scenario.fromFirestore(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList(); // Explicitly map to List<Scenario>
    } catch (e) {
      print("Error fetching scenarios: $e");
      return [];
    }
  }

  Future<void> updateScenarioInFirebase(String docId, Scenario scenario) async {
    try {
      await _firestore
          .collection('scenarios')
          .doc(docId)
          .update(scenario.toFirestore());
    } catch (e) {
      print("Error updating scenario: $e");
      throw Exception("Failed to update scenario");
    }
  }

  Future<void> addScenarioToFirebase(Scenario newScenario) async {
    try {
      await _firestore.collection('scenarios').add(newScenario.toFirestore());
    } catch (e) {
      print("Error adding scenario: $e");
      throw Exception("Failed to add scenario");
    }
  }

  Future<List<Map<String, dynamic>>> fetchTestCasesForScenario(
      String scenarioId) async {
    try {
      // Fetch the test cases of the given scenario from Firestore
      QuerySnapshot snapshot = await _firestore
          .collection('scenarios')
          .doc(scenarioId)
          .collection('testCases')
          .get();

      return snapshot.docs.map((doc) {
        return {'docId': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      print("Error fetching test cases for scenario $scenarioId: $e");
      return []; // Return an empty list if an error occurs
    }
  }

  // Add a test case to a specific scenario
  Future<void> addTestCaseToScenario(
      String scenarioId, Map<String, dynamic> testCaseData) async {
    try {
      // Add the test case to the testCases subcollection of the scenario
      await _firestore
          .collection('scenarios')
          .doc(scenarioId)
          .collection('testCases')
          .add(testCaseData);
    } catch (e) {
      print("Error adding test case: $e");
      throw Exception("Failed to add test case");
    }
  }
}
