const Attendance = artifacts.require("Attendance");

contract("Attendance", accounts => {
  let attendance;
  const [owner, student1, student2] = accounts;

  // Avant chaque test, déployez un nouveau contrat
  beforeEach(async () => {
    attendance = await Attendance.new();
  });

  it("should deploy the contract", async () => {
    // Vérifiez que le contrat est déployé avec succès
    const ownerAddress = await attendance.owner();
    assert.equal(ownerAddress, owner, "Le propriétaire du contrat est incorrect");
  });

  it("should mark attendance as present", async () => {
    // Marquer la présence d'un étudiant
    await attendance.markAttendance(student1, true, { from: owner });

    // Vérifier que la présence a été marquée
    const isPresent = await attendance.getAttendance(student1);
    assert.equal(isPresent, true, "La présence n'a pas été correctement marquée");
  });

  it("should mark attendance as absent", async () => {
    // Marquer la présence de l'étudiant comme absente
    await attendance.markAttendance(student2, false, { from: owner });

    // Vérifier que la présence a été marquée comme absente
    const isPresent = await attendance.getAttendance(student2);
    assert.equal(isPresent, false, "La présence n'a pas été correctement marquée comme absente");
  });

  it("should only allow the owner to mark attendance", async () => {
    try {
      // Essayer de marquer la présence sans être le propriétaire du contrat
      await attendance.markAttendance(student1, true, { from: student2 });
      assert.fail("Seul le propriétaire devrait pouvoir marquer la présence");
    } catch (error) {
      assert(error.message.includes("Vous n'êtes pas autorisé!"), "Le message d'erreur est incorrect");
    }
  });
});
