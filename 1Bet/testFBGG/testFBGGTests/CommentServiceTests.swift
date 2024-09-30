//
//  CommentServiceTests.swift
//  testFBGGTests
//
//  Created by Florian Peyrony on 23/09/2024.
//

import XCTest
@testable import testFBGG



class CommentServiceTests: XCTestCase {

    var commentService: CommentService!

    override func setUp() {
        super.setUp()
        commentService = CommentService() // Initialiser le service
    }

    func testAddComment() {
        // Simuler les données d'un commentaire
        let commentData: [String: Any] = [
            "likes": 5,
            "nameOfWriter": "Florian",
            "comment": "C'est un super post !",
            "publicationID": "123",
            "isLiked": true
        ]
        
        // Ajouter un commentaire
        commentService.addComment(data: commentData)
        
        // Vérifier que le commentaire a été ajouté
        XCTAssertEqual(commentService.comments.count, 1, "Expected one comment to be added.")
        XCTAssertEqual(commentService.comments[0].nameOfWriter, "Florian", "Expected writer to be Florian.")
        XCTAssertEqual(commentService.comments[0].commentText, "C'est un super post !", "Expected comment text to match.")
        XCTAssertEqual(commentService.comments[0].likes, 5, "Expected 5 likes.")
        XCTAssertTrue((commentService.comments[0].isLiked != nil), "Expected isLiked to be true.")
    }
    
    func testGetCommentsForPublicationID() {
        // Ajouter plusieurs commentaires
        let commentData1: [String: Any] = [
            "likes": 5,
            "nameOfWriter": "Florian",
            "comment": "Super post !",
            "publicationID": 123,
            "isLiked": false
        ]
        
        let commentData2: [String: Any] = [
            "likes": 3,
            "nameOfWriter": "Alice",
            "comment": "Bien joué !",
            "publicationID": 456,
            "isLiked": true
        ]
        
        commentService.addComment(data: commentData1)
        commentService.addComment(data: commentData2)
        
        // Récupérer les commentaires pour publicationID 123
        let commentsForPublication123 = commentService.getComments(forPublicationID: "123")
        
        // Vérifier que seul le commentaire avec publicationID 123 est récupéré
        XCTAssertEqual(commentsForPublication123.count, 1, "Expected 1 comment for publication 123.")
        XCTAssertEqual(commentsForPublication123[0].nameOfWriter, "Florian", "Expected writer to be Florian for publication 123.")
    }
}
