-- so that we can do quick tests
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS question_followers;
DROP TABLE IF EXISTS question_replies;
DROP TABLE IF EXISTS question_actions;
DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS question_action_type;

CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  is_instructor TINYINT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,
  FOREIGN KEY(author_id) REFERENCES users(id)
);

CREATE TABLE question_followers (
  question_id INTEGER NOT NULL,
  follower_id INTEGER NOT NULL,
  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(follower_id) REFERENCES users(id)
);

CREATE TABLE question_replies (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  parent_id INTEGER,
  question_id INTEGER NOT NULL,
  reply_body TEXT NOT NULL,
  author_id INTEGER NOT NULL,
  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(parent_id) REFERENCES question_replies(id),
  FOREIGN KEY(author_id) REFERENCES users(id)
);

CREATE TABLE question_actions (
  question_id INTEGER NOT NULL,
  type_id INTEGER,
  time TIMESTAMP DEFAULT (datetime('now','localtime')),
  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(type_id) REFERENCES question_action_type(id)
);

CREATE TABLE question_likes (
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE question_action_type(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type VARCHAR(20) NOT NULL
);


INSERT INTO question_action_type ('type')
     VALUES ('retract'), ('close'), ('reopen');

INSERT INTO users
     VALUES (1, 'Peter','Lin', 1),
            (2, 'Nick','Awesome', 0),
            (3, 'Eric','Lin', 1),
            (4, 'Nate', 'Hayflick', 0);

INSERT INTO questions
     VALUES (1, 'What the fuck?', 'Is this even working? Should we be inserting into our tables to test our methods?', 2),
            (2, 'More question?', 'blah blah blah', 1);

INSERT INTO question_followers
     VALUES (1, 3), (1, 4), (2, 3);

INSERT INTO question_replies
     VALUES (1, NULL, 1, "Hope so!", 1), (2, 1, 1, "This is a reply!", 2), (3, 2, 1, "This is another reply!", 3), (4, 2, 1, "This is the final reply",1);

INSERT INTO question_actions (question_id, type_id)
     VALUES (2, 2);

INSERT INTO question_likes
     VALUES (1, 4), (1, 3), (2, 4);



-- Here I cheat and assume that mathematics has id #1, physics id #2.
-- INSERT INTO professors ('first_name', 'last_name', 'department_id')
--      VALUES ('Albert', 'Einstein', 2), ('Kurt', 'Godel', 1);