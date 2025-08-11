const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const serviceAccount = {
  // This will use the default Firebase credentials from your project
};

if (!admin.apps.length) {
  try {
    admin.initializeApp({
      projectId: 'cyclesync-tracker'
    });
    console.log('Firebase Admin initialized successfully');
  } catch (error) {
    console.error('Error initializing Firebase Admin:', error);
    process.exit(1);
  }
}

const db = admin.firestore();
const userId = '4GEkV6hItgUgrZNPLMl3ES4mXOm2';

async function addSampleData() {
  try {
    console.log('Adding sample cycles...');
    
    // Add sample completed cycles
    const cycles = [
      {
        startDate: admin.firestore.Timestamp.fromDate(new Date('2024-06-15')),
        endDate: admin.firestore.Timestamp.fromDate(new Date('2024-06-19')),
        length: 4,
        flowIntensity: 'medium',
        symptoms: ['cramps', 'mood_swings'],
        notes: 'Normal cycle, moderate flow',
        isComplete: true,
        createdAt: admin.firestore.Timestamp.fromDate(new Date('2024-06-15')),
        updatedAt: admin.firestore.Timestamp.fromDate(new Date('2024-06-19'))
      },
      {
        startDate: admin.firestore.Timestamp.fromDate(new Date('2024-07-12')),
        endDate: admin.firestore.Timestamp.fromDate(new Date('2024-07-17')),
        length: 5,
        flowIntensity: 'heavy',
        symptoms: ['cramps', 'fatigue', 'bloating'],
        notes: 'Heavy flow cycle with stronger symptoms',
        isComplete: true,
        createdAt: admin.firestore.Timestamp.fromDate(new Date('2024-07-12')),
        updatedAt: admin.firestore.Timestamp.fromDate(new Date('2024-07-17'))
      },
      {
        startDate: admin.firestore.Timestamp.fromDate(new Date('2024-08-09')),
        endDate: admin.firestore.Timestamp.fromDate(new Date('2024-08-13')),
        length: 4,
        flowIntensity: 'light',
        symptoms: ['mood_swings'],
        notes: 'Light cycle with minimal symptoms',
        isComplete: true,
        createdAt: admin.firestore.Timestamp.fromDate(new Date('2024-08-09')),
        updatedAt: admin.firestore.Timestamp.fromDate(new Date('2024-08-13'))
      },
      {
        startDate: admin.firestore.Timestamp.fromDate(new Date('2024-09-05')),
        endDate: admin.firestore.Timestamp.fromDate(new Date('2024-09-09')),
        length: 4,
        flowIntensity: 'medium',
        symptoms: ['cramps', 'headache'],
        notes: 'Regular cycle with headaches',
        isComplete: true,
        createdAt: admin.firestore.Timestamp.fromDate(new Date('2024-09-05')),
        updatedAt: admin.firestore.Timestamp.fromDate(new Date('2024-09-09'))
      },
      {
        startDate: admin.firestore.Timestamp.fromDate(new Date('2024-10-02')),
        endDate: admin.firestore.Timestamp.fromDate(new Date('2024-10-06')),
        length: 4,
        flowIntensity: 'medium',
        symptoms: ['cramps'],
        notes: 'Normal cycle',
        isComplete: true,
        createdAt: admin.firestore.Timestamp.fromDate(new Date('2024-10-02')),
        updatedAt: admin.firestore.Timestamp.fromDate(new Date('2024-10-06'))
      },
      {
        startDate: admin.firestore.Timestamp.fromDate(new Date('2024-10-29')),
        endDate: admin.firestore.Timestamp.fromDate(new Date('2024-11-02')),
        length: 4,
        flowIntensity: 'medium',
        symptoms: ['cramps', 'mood_swings'],
        notes: 'Recent cycle',
        isComplete: true,
        createdAt: admin.firestore.Timestamp.fromDate(new Date('2024-10-29')),
        updatedAt: admin.firestore.Timestamp.fromDate(new Date('2024-11-02'))
      }
    ];

    // Add cycles to Firestore
    for (let i = 0; i < cycles.length; i++) {
      const cycleRef = db.collection('users').doc(userId).collection('cycles').doc();
      await cycleRef.set(cycles[i]);
      console.log(`Added cycle ${i + 1}: ${cycles[i].startDate.toDate().toDateString()} - ${cycles[i].endDate.toDate().toDateString()}`);
    }

    console.log('Adding sample daily logs...');

    // Add sample daily logs
    const dailyLogs = [
      {
        date: admin.firestore.Timestamp.fromDate(new Date('2024-11-15')),
        mood: 'happy',
        energyLevel: 8,
        sleepQuality: 7,
        symptoms: ['cramps'],
        notes: 'Feeling good today',
        weight: 65.5,
        waterIntake: 2000,
        exercise: 'walking',
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        date: admin.firestore.Timestamp.fromDate(new Date('2024-11-16')),
        mood: 'neutral',
        energyLevel: 6,
        sleepQuality: 6,
        symptoms: ['bloating', 'mood_swings'],
        notes: 'Average day',
        weight: 65.8,
        waterIntake: 1800,
        exercise: 'yoga',
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      },
      {
        date: admin.firestore.Timestamp.fromDate(new Date('2024-11-17')),
        mood: 'happy',
        energyLevel: 9,
        sleepQuality: 8,
        symptoms: [],
        notes: 'Great energy today!',
        weight: 65.2,
        waterIntake: 2200,
        exercise: 'running',
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      }
    ];

    // Add daily logs to Firestore
    for (let i = 0; i < dailyLogs.length; i++) {
      const logRef = db.collection('users').doc(userId).collection('daily_logs').doc();
      await logRef.set(dailyLogs[i]);
      console.log(`Added daily log ${i + 1}: ${dailyLogs[i].date.toDate().toDateString()}`);
    }

    console.log('✅ Sample data added successfully!');
    console.log(`Added ${cycles.length} cycles and ${dailyLogs.length} daily logs for user ${userId}`);

  } catch (error) {
    console.error('Error adding sample data:', error);
  } finally {
    process.exit(0);
  }
}

addSampleData();
