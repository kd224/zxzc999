
// If user is using a multiple accounts, userId column is used to differentiate data belonging to each user.
const tables_decks = '''
        CREATE TABLE decks(
          id STRING PRIMARY KEY, 
          userId STRING,
          createdAt INTEGER DEFAULT 0,
          lastPlayed INTEGER DEFAULT 0, 
          lastUpdated INTEGER, 
          title TEXT, 
          cards_amount INTEGER DEFAULT 0,
        )
        ''';

const tables_cards = '''
        CREATE TABLE cards(
          id STRING PRIMARY KEY,
          deck_id STRING,
          lastUpdated INTEGER,
          front TEXT, 
          back TEXT,
          frontImg TEXT DEFAULT null,
          backImg TEXT DEFAULT null,
          frontMP3 TEXT DEFAULT null,
          backMP3 TEXT DEFAULT null,
          grade INTEGER,
          schedule INTEGER,
          interval INTEGER,
          repetitions INTEGER,
          ease_factor FLOAT
        )
        ''';

const tables_decksToSync = '''
        CREATE TABLE decksToSync(
          id STRING PRIMARY KEY,
          operation STRING
        )''';

const tables_cardsToSync = '''
        CREATE TABLE cardsToSync(
          id INTEGER PRIMARY KEY,
          deck_id STRING,
          card_id STRING,
          operation STRING
        )
        ''';
